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
    "__Z": .itanium,
]

// https://itanium-cxx-abi.github.io/cxx-abi/abi.html#mangle.builtin-type
public let itaniumParamTypes: [String: String] = [
    "v": "void",
    "w": "wchar_t",
    "b": "bool",
    "c": "char",
    "a": "signed char",
    "h": "unsigned char",
    "s": "short",
    "t": "unsigned short",
    "i": "int",
    "j": "unsigned int",
    "l": "long",
    "m": "unsigned long",
    "x": "long long, __int64",
    "y": "unsigned long long",
    "n": "__int128",
    "o": "unsigned __int128",
    "f": "float",
    "d": "double",
    "e": "long double",
    "g": "__float128",
    "z": "ellipsis",
    "St": "::std::",
    "Sa": "::std::allocator::",
    "Sb": "::std::basic_string",
    "So": "::std::ostream",
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
        var prefix_length = 2
        if self.name.hasPrefix("__") {
            prefix_length = 3
        }
        let prefix: String.SubSequence = self.name.prefix(prefix_length)
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
    public var param_types: [String] = []
    public var demangled: String? = Optional.none

    public required init(symbol: MangledSymbol) {
        self.symbol = symbol
        self.parse()

        print(self.symbol.name)
        print(self.demangled_symbol())
    }

    public func demangled_symbol() -> String {
        var res = ""
        res += identifiers.joined(separator: "::")
        res += "("
        res += param_types.filter({
            $0 != "void"
        }).joined(separator: ", ")
        res += ")"
        return res
    }

    public func parse() {
        n_index = self.symbol.name.firstIndex(of: "N")
        var ident_len: Int? = Optional.none
        var ident_start: String.Index? = Optional.none
        var ident_end: String.Index? = Optional.none
        var end_index: String.Index? = Optional.none

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
            end_index = self.symbol.name.index(ident_end!, offsetBy: ident_len!)
            ident_start = self.symbol.name[end_index!...].firstIndex(where: {
                $0.wholeNumberValue != nil
            })
        }

        // start at end_index
        //increment by one and check map
        //  if a check: set end_index to the amount incremented by
        //  else increment by one
        // do until end

        var s_idx = end_index!
        var e_idx = s_idx

        // check for end of function notifier
        if String(self.symbol.name[s_idx...e_idx]) == "E" {
            print("End of function")
            s_idx = self.symbol.name.index(after: e_idx)
            e_idx = s_idx
        }

        var ref = false

        while e_idx < self.symbol.name.endIndex {
            let return_type = String(self.symbol.name[s_idx...e_idx])
            if return_type == "R" {
                ref = true
                s_idx = self.symbol.name.index(after: e_idx)
            }
            if itaniumParamTypes.keys.contains(return_type) {
                var val = itaniumParamTypes[return_type, default: "Uknown"]
                if ref {
                    ref = false
                    val.append("&")
                }
                if val.hasPrefix("::") {
                    val.removeFirst(2)
                }
                self.param_types.append(val)
                s_idx = self.symbol.name.index(after: e_idx)
            }
            e_idx = self.symbol.name.index(after: e_idx)
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
