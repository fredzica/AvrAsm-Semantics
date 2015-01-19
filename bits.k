// Copyright (c) 2014 Frederico Zica. All Rights Reserved.

require "builtins/mint.k"

module BITS
imports MINT

    // ToByte
    syntax MInt ::= toByte(Int) [function]
    rule toByte(I:Int) => mi(8, I) [macro]

    // Bool from MInt
    syntax Bool ::= bit(MInt, Int) [function]
    rule bit(M:MInt, B:Int) => neMInt(andMInt(M, toByte(1 <<Int B)), toByte(0))

    // Modify bit from MInt
    syntax MInt ::= setf(MInt, Int) [function] 
    syntax MInt ::= clrf(MInt, Int) [function]
    rule setf(M:MInt, B:Int) => orMInt(M, toByte(1 <<Int B))
    rule clrf(M:MInt, B:Int) => andMInt(M, toByte(~Int (1 <<Int B)))

    syntax Int ::= BooltoInt(Bool) [function]
    rule BooltoInt(false) => 0
    rule BooltoInt(true) => 1

    syntax MInt ::= BooltoMInt(Bool) [function]
    rule BooltoMInt(false) => toByte(0)
    rule BooltoMInt(true) => toByte(1)

    // Signed shift right TODO: move to the right place
    syntax MInt ::= sshrMInt(MInt, Int) [function]
    rule sshrMInt(M1:MInt, I:Int) => toByte(uvalueMInt(toByte(svalueMInt(M1) >>Int I)))


endmodule
