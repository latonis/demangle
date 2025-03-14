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

        var p: Parser

        switch self.type {
        case .itanium: p = CppParser(symbol: self)
        default: p = UnknownParser(symbol: self)
        }

        p.parse()
        return ""
    }
}

public protocol Parser {
    var symbol: MangledSymbol { get set }
    var pref: String { get set }
    init(symbol: MangledSymbol)
    mutating func parse()
}

public class CppParser: Parser {
    public var symbol: MangledSymbol
    public var pref = "_Z"
    public var n_index: String.Index? = Optional.none
    public var identifiers: [String] = []
    public var demangled: String? = Optional.none
    public required init(symbol: MangledSymbol) {
        self.symbol = symbol
        self.parse()
    }

    public func parse() {
        n_index = self.symbol.name.firstIndex(of: "N")
        var ident_len: Int? = Optional.none
        var ident_start: String.Index? = Optional.none
        var ident_end: String.Index? = Optional.none

        ident_start = self.symbol.name.firstIndex(where: { $0.wholeNumberValue != nil })
        ident_end = self.symbol.name.firstIndex(where: { $0.wholeNumberValue != nil })
        while ident_start != Optional.none {
            if let ident_start = ident_start {
                ident_end = self.symbol.name[ident_start...].firstIndex(where: {
                    $0.wholeNumberValue == nil
                })
            }

            if let start_idx = ident_start, let end_idx = ident_end {
                ident_len = Int(
                    self.symbol.name[start_idx...self.symbol.name.index(before: end_idx)])
                identifiers.append(
                    String(
                        self.symbol.name[
                            end_idx...self.symbol.name.index(end_idx, offsetBy: ident_len! - 1)]))
            }
            ident_start = self.symbol.name[self.symbol.name.index(ident_end!, offsetBy: ident_len!)...].firstIndex(where: { $0.wholeNumberValue != nil })
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
