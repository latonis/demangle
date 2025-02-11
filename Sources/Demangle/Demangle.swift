/// A description
enum Compiler: String {
    case itanium
    case rust
    case swift
    case unknown
}

let compilerPrefixes = [
    "_Z": Compiler.itanium,
    "_R": .rust,
]

public class MangledSymbol {
    public let name: String
    let type: Compiler

    public init(name: String) {
        self.name = name
        self.type = Compiler.unknown
    }

    public func demangle() -> String {
        // parse the string
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
        // func name
        // params
    }

    func prefix() {
        let prefix = self.symbol.name.prefix(2)
        print(prefix)
    }
}
