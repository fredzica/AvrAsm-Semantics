module UNIT_TEST_SYNTAX
    //TODO: create configuration to enable or disable this part
    syntax Stmt ::= UnitTest

    syntax UnitTest ::= "vreg" Reg "," Exp
                    | "vpin" IOReg "," Exp
                    | "vsreg" Exp
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

    rule <k> vreg Reg, V => . </k>
        <registers>... Reg |-> mi(8, V) ...</registers>
    
    rule <k> vpin Pin, V => . </k>
        <pins>... Pin |-> mi(8, V) ...</pins>
    
    rule <k> vi V => . </k>
        <ri> V </ri>

    rule <k> vt V => . </k>
        <rt> V </rt>

    rule <k> vh V => . </k>
        <rh> V </rh>

    rule <k> vs V => . </k>
        <rs> V </rs>

    rule <k> vv V => . </k>
        <rv> V </rv>

    rule <k> vn V => . </k>
        <rn> V </rn>

    rule <k> vz V => . </k>
        <rz> V </rz>

    rule <k> vc V => . </k>
        <rc> V </rc>

    rule <k> vsreg B => . </k>
        <rc> Vc </rc>
        <rz> Vz </rz>
        <rn> Vn </rn>
        <rv> Vv </rv>
        <rs> Vs </rs>
        <rh> Vh </rh>
        <rt> Vt </rt>
        <ri> Vi </ri>
        when (Boolasbin(Vc, 0) +Int Boolasbin(Vz, 1) +Int Boolasbin(Vn, 2) +Int Boolasbin(Vv, 3) +Int Boolasbin(Vs, 4) +Int Boolasbin(Vh, 5) +Int Boolasbin(Vt, 6) +Int Boolasbin(Vi, 7)) ==Int B

    syntax Int ::= Boolasbin(Bool, Int) [function]
    rule Boolasbin(false, I) => 0
    rule Boolasbin(true, I) => 2 ^Int I

endmodule
