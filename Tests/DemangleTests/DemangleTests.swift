import Demangle
import Testing

struct CoreTests {
    @Test
    func initMangledSymbol() {
        let expected = "symbol_test"
        let sym = Demangle.MangledSymbol(name: "symbol_test")

        #expect(sym.name == expected)
        #expect(sym.type == Demangle.Compiler.unknown)
    }
}

struct RustTests {
    @Test func type() {
        let input = "_RNvCs15kBYyAo9fc_7mycrate7example"
        let sym = Demangle.MangledSymbol(name: input)
        #expect(sym.type == Demangle.Compiler.rust)
    }
}

struct CppTests {
    @Test func type() {
        let input = "_ZN9wikipedia7article6formatEv"
        let sym = Demangle.MangledSymbol(name: input)
        #expect(sym.type == Demangle.Compiler.itanium)
    }

    @Test func parse() {
        let input = "_ZN9wikipedia7article6formatEv"
        let sym = Demangle.MangledSymbol(name: input)
        let parser = Demangle.CppParser(symbol: sym)
        print(parser.identifiers)
        #expect(parser.n_index != nil)
        #expect(
            parser.symbol.name.distance(from: parser.symbol.name.startIndex, to: parser.n_index!)
                == 2)
        #expect(parser.identifiers.count == 3)
        #expect(parser.param_types == ["void"])
        #expect(parser.demangled_symbol() == "wikipedia::article::format()")
    }

    @Test func parse_generated() {
        let input = "__ZN4test3fooEi"
        let sym = Demangle.MangledSymbol(name: input)
        let parser = Demangle.CppParser(symbol: sym)

        #expect(parser.demangled_symbol() == "test::foo(int)")
        #expect(parser.param_types == ["int"])
    }

     @Test func parse_complicated() {
         let input = "_ZN9wikipedia7article8print_toERSo"
         let sym = Demangle.MangledSymbol(name: input)
         let parser = Demangle.CppParser(symbol: sym)
         #expect(parser.param_types == ["std::ostream&"])
         #expect(parser.demangled_symbol() == "wikipedia::article::print_to()")
     }
}

struct SwiftTests {
    @Test func type() {
        let input = "_TFC4test7MyClass9calculatefS0_FT1xSi_Si"
        let sym = Demangle.MangledSymbol(name: input)
        #expect(sym.type == Demangle.Compiler.swift)
    }
}
