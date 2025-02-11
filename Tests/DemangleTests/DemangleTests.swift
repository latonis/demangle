import Demangle
import Testing


struct CoreTests {
    @Test
    func initMangledSymbol() {
        let expected = "symbol_test"
        let sym = Demangle.MangledSymbol(name: "symbol_test")

        #expect(sym.name == expected)
    }
}

struct RustTests {
    @Test func basic() {
        let expected = "foo::bar"
        let input = "NN3foo3bar"

        let sym = Demangle.MangledSymbol(name: input)

        #expect(sym.demangle() == expected)
    }
}
