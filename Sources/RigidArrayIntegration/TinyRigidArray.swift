public import BasicContainers
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
public typealias TinyRigidArray<
    Element,
    InlineElements: _InlineElements
> = TinySequence<
    Element,
    InlineElements,
    RigidArray<Element>
>
where
    Element: BitwiseCopyable,
    InlineElements.Element == Element

@available(swiftTinySequenceApplePlatforms 10.15, *)
public typealias TinyRigidArray23<
    Element
> = TinyRigidArray<
    Element,
    InlineElements23<Element>
>
where
    Element: BitwiseCopyable
