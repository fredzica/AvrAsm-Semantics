// Copyright (c) 2014 Frederico Zica. All Rights Reserved.

module UNIT_TEST-SYNTAX

    syntax Stmt ::= UnitTest

    syntax UnitTest ::= "vmem" Int "," Int
                    | "vsreg" Int
                    | "vclk" Int
                    | "vstack" Int
                    | "vi" Bool
                    | "vt" Bool
                    | "vh" Bool
                    | "vs" Bool
                    | "vv" Bool
                    | "vn" Bool
                    | "vz" Bool
                    | "vc" Bool
endmodule

module UNIT_TEST
imports UNIT_TEST-SYNTAX
imports MINT
imports BITS

    rule <k> vmem A:Int, V:Int => .K </k>
        <dataspace>... A |-> mi(8, V) ...</dataspace>
    
    rule <k> vi V:Bool => .K </k>
        <ri> V </ri>

    rule <k> vt V:Bool => .K </k>
        <rt> V </rt>

    rule <k> vh V:Bool => .K </k>
        <rh> V </rh>

    rule <k> vs V:Bool => .K </k>
        <rs> V </rs>

    rule <k> vv V:Bool => .K </k>
        <rv> V </rv>

    rule <k> vn V:Bool => .K </k>
        <rn> V </rn>

    rule <k> vz V:Bool => .K </k>
        <rz> V </rz>

    rule <k> vc V:Bool => .K </k>
        <rc> V </rc>

    rule <k> vsreg B:Int => .K </k>
        <rc> Vc:Bool </rc>
        <rz> Vz:Bool </rz>
        <rn> Vn:Bool </rn>
        <rv> Vv:Bool </rv>
        <rs> Vs:Bool </rs>
        <rh> Vh:Bool </rh>
        <rt> Vt:Bool </rt>
        <ri> Vi:Bool </ri>
        when (Boolasbin(Vc, 0) +Int Boolasbin(Vz, 1) +Int Boolasbin(Vn, 2) +Int Boolasbin(Vv, 3) +Int Boolasbin(Vs, 4) +Int Boolasbin(Vh, 5) +Int Boolasbin(Vt, 6) +Int Boolasbin(Vi, 7)) ==Int B

    rule <k> vclk Clk:Int => .K </k>
        <clockcycle> Clk </clockcycle>
    
    rule <k> vstack E:Int => .K </k>
        <spaddr> SPA:Int </spaddr>
        <dataspace> M:Map (SPA |-> MI:MInt) (uvalueMInt(addMInt(MI, toByte(1))) |-> toByte(E)) </dataspace>

    syntax Int ::= Boolasbin(Bool, Int) [function]
    rule Boolasbin(false, _) => 0
    rule Boolasbin(true, I:Int) => 2 ^Int I

endmodule
