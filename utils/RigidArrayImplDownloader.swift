#!/usr/bin/env swift
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let repoOwner = "swiftlang"
let repoName = "swift"
let ref = "release/6.4.x"
let sourceModule = "stdlib/public/core/RigidArray"
let outputDir = "Sources/RigidArrayImpl"

struct GitHubFile: Codable {
    let name: String
    let path: String
    let type: String
    let download_url: String?
    let url: String
}

let fileManager = FileManager.default

func fetchWithRetries(url: URL) throws -> Data {
    let maxAttempts = 5
    for attempts in 1...maxAttempts {
        do {
            return try Data(contentsOf: url)
        } catch {
            if attempts == maxAttempts {
                throw error
            } else {
                print("✗ Failed to fetch \(url.absoluteString): \(String(reflecting: error))")
                print("Retrying in 3 seconds...")
                sleep(3)
            }
        }
    }
    fatalError("Unreachable")
}

func fetchDirectoryContents(apiUrl: String) throws -> [GitHubFile] {
    let url = URL(string: apiUrl)!
    let data = try fetchWithRetries(url: url)
    return try JSONDecoder().decode([GitHubFile].self, from: data)
}

func replace(bytes: Data, with newBytes: Data, in data: inout Data) {
    var searchIndex = data.startIndex
    while let range = data.range(of: bytes, in: searchIndex..<data.endIndex) {
        data.replaceSubrange(range, with: newBytes)
        searchIndex = range.lowerBound + newBytes.count
    }
}

func applyModifications(to data: inout Data, fileName: String) {
    replace(
        bytes: Data("@available(SwiftStdlib 6.4, *)".utf8),
        with: Data("@available(SwiftStdlib 5.1, *)".utf8),
        in: &data
    )

    replace(
        bytes: Data("_precondition(".utf8),
        with: Data("precondition(".utf8),
        in: &data
    )
    replace(
        bytes: Data("_internalInvariant(".utf8),
        with: Data("assert(".utf8),
        in: &data
    )

    // The `borrow`/`mutate` accessors are Swift 6.4 only.
    // Provide the equivalent unsafe accessors for 6.3.
    replace(
        bytes: Data(
            """
              @available(SwiftStdlib 5.1, *)
              @_alwaysEmitIntoClient
              internal subscript(position: Int) -> Element {
                @_transparent
                @_unsafeSelfDependentResult
                borrow {
                  unsafe _ptr(to: position).pointee
                }

                @_transparent
                @_unsafeSelfDependentResult
                mutate {
                  unsafe &_mutablePtr(to: position).pointee
                }
              }
            """.utf8
        ),
        with: Data(
            """
              #if compiler(>=6.4)
              @available(SwiftStdlib 5.1, *)
              @_alwaysEmitIntoClient
              internal subscript(position: Int) -> Element {
                @_transparent
                @_unsafeSelfDependentResult
                borrow {
                  unsafe _ptr(to: position).pointee
                }

                @_transparent
                @_unsafeSelfDependentResult
                mutate {
                  unsafe &_mutablePtr(to: position).pointee
                }
              }
              #else
              @available(SwiftStdlib 5.1, *)
              @_alwaysEmitIntoClient
              internal subscript(position: Int) -> Element {
                @_transparent
                unsafeAddress {
                  unsafe _ptr(to: position)
                }

                @_transparent
                unsafeMutableAddress {
                  unsafe _mutablePtr(to: position)
                }
              }
              #endif
            """.utf8
        ),
        in: &data
    )

    replace(
        bytes: Data(
            """
              deinit {
                unsafe _storage.extracting(0 ..< _count).deinitialize()
                unsafe _storage.deallocate()
              }
            """.utf8
        ),
        with: Data(
            """
              deinit {
                // ManagedRigidArray does not own its storage.
                // The initializers are responsible for deinitializing the elements.
              }
            """.utf8
        ),
        in: &data
    )

    // Rename the vendored type to make clear it is a modified (non-owning)
    // copy of the standard library's RigidArray rather than the real thing.
    replace(
        bytes: Data("_RigidArray".utf8),
        with: Data("ManagedRigidArray".utf8),
        in: &data
    )

    replace(
        bytes: Data("internal ".utf8),
        with: Data("package ".utf8),
        in: &data
    )

    // `Equatable` / `Hashable` conformances for noncopyable elements rely on
    // the 6.4 standard library relaxing those protocols to allow `~Copyable`.
    // There is no 6.3 equivalent, so the whole file is gated to 6.4.
    if fileName == "RigidArray+Equatable.swift" || fileName == "RigidArray+Hashable.swift" {
        data =
            Data("#if compiler(>=6.4)\n".utf8) + data + Data("#endif\n".utf8)
    }
}

func downloadAndWriteFile(name: String, from url: String, to outputPath: String) throws -> Int {
    var data = try fetchWithRetries(url: URL(string: url)!)
    print("✓ Downloaded \(name) (\(data.count) bytes)")

    applyModifications(to: &data, fileName: name)

    let directory = URL(fileURLWithPath: outputPath).deletingLastPathComponent().path
    if !fileManager.fileExists(atPath: directory) {
        try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true)
    }

    if let currentContents = fileManager.contents(atPath: outputPath),
        currentContents == data
    {
        print("✓ File \(outputPath) already exists and is up to date")
        return data.count
    } else {
        print("✓ Writing to \(outputPath) ...")
        try data.write(to: URL(fileURLWithPath: outputPath))
        return data.count
    }
}

func downloadDirectoryRecursively(
    apiUrl: String,
    relativePath: String? = nil
) throws -> (files: Int, bytes: Int) {
    print("Fetching directory contents from: \(apiUrl)")
    let contents = try fetchDirectoryContents(apiUrl: apiUrl)

    var totalFiles = 0
    var totalBytes = 0

    for item in contents {
        // The vendored type is renamed `_RigidArray` -> `ManagedRigidArray`, so
        // rename the files to match (e.g. `RigidArray+Append.swift` becomes
        // `ManagedRigidArray+Append.swift`).
        let outputName = item.name.replacingOccurrences(
            of: "RigidArray",
            with: "ManagedRigidArray"
        )
        let outputPath =
            if let relativePath {
                "\(outputDir)/\(relativePath)/\(outputName)"
            } else {
                "\(outputDir)/\(outputName)"
            }

        if item.type == "file" {
            guard let downloadURL = item.download_url else {
                print("✗ No download URL for \(item.name), skipping")
                continue
            }
            print("Downloading \(item.name) ...")
            let bytes = try downloadAndWriteFile(
                name: item.name,
                from: downloadURL,
                to: outputPath
            )
            totalFiles += 1
            totalBytes += bytes
        } else if item.type == "dir" {
            print("📁 Found subdirectory: \(item.name)")
            let subRelativePath =
                if let relativePath {
                    "\(relativePath)/\(item.name)"
                } else {
                    item.name
                }

            let (subFiles, subBytes) = try downloadDirectoryRecursively(
                apiUrl: item.url,
                relativePath: subRelativePath
            )
            totalFiles += subFiles
            totalBytes += subBytes
        }
    }

    return (files: totalFiles, bytes: totalBytes)
}

func downloadRigidArrayImpl() {
    let currentDirectory = fileManager.currentDirectoryPath
    guard currentDirectory.hasSuffix("swift-tiny-sequence") else {
        fatalError(
            "This script must be run from the swift-tiny-sequence root directory. Current directory: \(currentDirectory)."
        )
    }

    let apiURL =
        "https://api.github.com/repos/\(repoOwner)/\(repoName)/contents/\(sourceModule)?ref=\(ref)"

    if !fileManager.fileExists(atPath: outputDir) {
        do {
            try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            print("Created directory: \(outputDir)")
        } catch {
            fatalError("Failed to create directory \(outputDir): \(String(reflecting: error))")
        }
    }

    print("🚀 Downloading RigidArray implementation from \(repoOwner)/\(repoName)@\(ref)...")
    do {
        let (totalFiles, totalBytes) = try downloadDirectoryRecursively(apiUrl: apiURL)
        print(
            "\n✅ Completed: Downloaded \(totalFiles) files (\(totalBytes) bytes total) from \(ref)"
        )
    } catch {
        print("✗ Failed to download RigidArray implementation: \(String(reflecting: error))")
        exit(1)
    }
}

downloadRigidArrayImpl()
print("Done!")
