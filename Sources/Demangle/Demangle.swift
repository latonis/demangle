/// A description
public enum Compiler: Sendable {
    case itanium
    case rust
    case swift
    case unknown
}

public let compilerPrefixes: [String: Compiler] = [
    "_Z": Compiler.itanium,
    "_R": .rust,
]

public class MangledSymbol {
    public let name: String
    public var type: Compiler

    public init(name: String) {
        self.name = name
        self.type = Compiler.unknown

        let _ = demangle()
    }

    public func demangle() -> String {
        let p = Parser(symbol: self)
        p.parse()
        return ""
    }
}

class Parser {
    let symbol: MangledSymbol

    public init(symbol: MangledSymbol) {
        self.symbol = symbol
    }

    func parse() {
        prefix()
    }

    func prefix() {
        let prefix: String.SubSequence = self.symbol.name.prefix(2)
        self.symbol.type = compilerPrefixes[String(prefix), default: Compiler.unknown]
    }
}
