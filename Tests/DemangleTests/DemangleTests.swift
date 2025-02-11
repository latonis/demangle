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
        let input = "_Z1hv"
        let sym = Demangle.MangledSymbol(name: input)
        #expect(sym.type == Demangle.Compiler.itanium)
    }
}

struct SwiftTests {
    @Test func type() {
        let input = "_TFC4test7MyClass9calculatefS0_FT1xSi_Si"
        let sym = Demangle.MangledSymbol(name: input)
        #expect(sym.type == Demangle.Compiler.swift)
    }
}
