public import BasicContainers
public import TinySequenceImpl

@available(swiftTinySequenceApplePlatforms 10.15, *)
public typealias TinyRigidArray<
    InlineElements: _InlineElements
> = TinySequence<
    InlineElements,
    RigidArray<InlineElements.Element>
>

@available(swiftTinySequenceApplePlatforms 10.15, *)
public typealias TinyRigidArray24<
    Element
> = TinyRigidArray<
    _InlineElements24<Element>
>
where
    Element: BitwiseCopyable
