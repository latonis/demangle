public enum Compiler: Sendable {
    case itanium
    case rust
    case swift
    case unknown
}

public let compilerType: [String: Compiler] = [
    "_R": Compiler.rust,
    "_T": .swift,
    "_Z": .itanium,
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
        let prefix: String.SubSequence = self.name.prefix(2)
        self.type = compilerType[String(prefix), default: Compiler.unknown]

        var p: Parser;

        switch self.type {
        case .itanium: p = CppParser(symbol: self)
        default: p = UnknownParser(symbol: self)
        }

        p.parse()
        return ""
    }
}

protocol Parser {
    var symbol: MangledSymbol { get set }
    var pref: String { get set }
    init(symbol: MangledSymbol)
    mutating func parse()
}

class CppParser: Parser {
    var symbol: MangledSymbol
    var pref = "_Z"

    public required init(symbol: MangledSymbol) {
        self.symbol = symbol
    }

    public init(p: Parser) {
        self.symbol = p.symbol
    }

    func parse() {
        if let n_index = self.symbol.name.firstIndex(of: "N") {
            print(n_index)
            print(self.symbol.name[n_index...])
        }
    }
}

class UnknownParser: Parser {
    var symbol: MangledSymbol
    var pref = ""

    public required init(symbol: MangledSymbol) {
        self.symbol = symbol
    }

    func parse() {
        print("Encountered an unknown mangling scheme!")
    }
}
