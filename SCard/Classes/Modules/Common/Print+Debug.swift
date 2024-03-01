func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(items, separator: separator, terminator: terminator)
    #elseif F_DEV
    Swift.print(items, separator: separator, terminator: terminator)
    #elseif F_TEST
    Swift.print(items, separator: separator, terminator: terminator)
    #elseif F_STAGING
    return
    #endif
}
