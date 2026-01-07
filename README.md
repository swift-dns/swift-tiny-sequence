# swift-tiny-sequence

A library for containing types for storing the initial elements of a sequence inline on the stack, and allocating on the heap for more storage if needed.

Such types are common in performance-sensitive code, but are not intended towards everyday users.

The prime example of such a type in Swift is `String`, which stores 15 utf8 bytes inline, +1 byte for metadata, so 16 bytes in total, and for any `String`s bigger than that, allocates on the heap.
