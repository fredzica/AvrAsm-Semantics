module UNIT_TEST_SYNTAX
    syntax Stmt ::= UnitTest

    syntax UnitTest ::= "vreg" Reg "," Exp
                    | "vpin" IOReg "," Exp
                    | "vsreg" Exp
                    | "vclk" Exp
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
imports UNIT_TEST_SYNTAX
imports MINT

    rule <k> vreg R:Reg, V:Int => . </k>
        <registers>... R |-> $mi(8, V) ...</registers>
    
    rule <k> vpin P:IOReg, V:Int => . </k>
        <pins>... P |-> $mi(8, V) ...</pins>
    
    rule <k> vi V:Bool => . </k>
        <ri> V </ri>

    rule <k> vt V:Bool => . </k>
        <rt> V </rt>

    rule <k> vh V:Bool => . </k>
        <rh> V </rh>

    rule <k> vs V:Bool => . </k>
        <rs> V </rs>

    rule <k> vv V:Bool => . </k>
        <rv> V </rv>

    rule <k> vn V:Bool => . </k>
        <rn> V </rn>

    rule <k> vz V:Bool => . </k>
        <rz> V </rz>

    rule <k> vc V:Bool => . </k>
        <rc> V </rc>

    rule <k> vsreg B:Int => . </k>
        <rc> Vc:Bool </rc>
        <rz> Vz:Bool </rz>
        <rn> Vn:Bool </rn>
        <rv> Vv:Bool </rv>
        <rs> Vs:Bool </rs>
        <rh> Vh:Bool </rh>
        <rt> Vt:Bool </rt>
        <ri> Vi:Bool </ri>
        when (Boolasbin(Vc, 0) +Int Boolasbin(Vz, 1) +Int Boolasbin(Vn, 2) +Int Boolasbin(Vv, 3) +Int Boolasbin(Vs, 4) +Int Boolasbin(Vh, 5) +Int Boolasbin(Vt, 6) +Int Boolasbin(Vi, 7)) ==Int B

    rule <k> vclk Clk:Int => . </k>
        <clockcycle> Clk </clockcycle>

    syntax Int ::= Boolasbin(Bool, Int) [function]
    rule Boolasbin(false, _) => 0
    rule Boolasbin(true, I:Int) => 2 ^Int I

endmodule
