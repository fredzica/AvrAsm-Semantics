module BITS
imports MINT

    // ToByte
    syntax MInt ::= toByte(Int) [function]
    rule toByte(I:Int) => mi(8, I) [macro]
    
    // Bool from MInt
    syntax Bool ::= bit(MInt, Int) [function]
    rule bit(M, B) => neMInt(andMInt(M, toByte(1 <<Int B)), toByte(0))

    // Modify bit from MInt
    syntax MInt ::= set(MInt, Int) [function] 
    syntax MInt ::= clr(MInt, Int) [function]
    rule set(M, B) => orMInt(M, toByte(1 <<Int B))
    rule clr(M, B) => andMInt(M, toByte(~Int (1 <<Int B)))

    syntax Int ::= BooltoInt(Bool) [function]
    rule BooltoInt(false) => 0
    rule BooltoInt(true) => 1

    syntax MInt ::= BooltoMInt(Bool) [function]
    rule BooltoMInt(false) => toByte(0)
    rule BooltoMInt(true) => toByte(1)

    // Signed shift right TODO: move to the right place
    syntax MInt ::= sshrMInt(MInt, Int) [function]
    rule sshrMInt(M1, I) => toByte(uvalueMInt(toByte(svalueMInt(M1) >>Int I)))


endmodule
