// Copyright (c) 2014 Frederico Zica. All Rights Reserved.

require "bits.k"
require "unittest.k"

module AVRASM-SYNTAX
imports UNIT_TEST-SYNTAX

    // Assembly mnemonics that have two general purpose registers as operands
    syntax RRStmt ::= "add"
                    | "mov"
                    | "sub"
                    | "eor"
                    | "cp"

    syntax RStmt ::= "push"
                    | "pop"
                    | "inc"
                    | "dec"
                    | "clr"
                    | "ser"
                    | "ror"
                    | "asr"
                    | "swap"
    
    syntax REStmt ::= "ldi" 
                    | "subi"
                    | "bst" 
                    | "bld"
    
    syntax RIStmt ::= "in"

    syntax IRStmt ::= "out"

    syntax IEStmt ::= "sbi"
                    | "cbi"

    // Assembly instructions
    syntax Stmt ::= RRStmt GReg "," GReg
                    | RStmt GReg
                    | REStmt GReg "," Exp [strict(2)]
                    | RIStmt GReg "," IOReg 
                    | IRStmt IOReg "," GReg 
                    | IEStmt IOReg "," Exp [strict(2)] 
                    | "bset" Exp [strict(1)]
                    | "bclr" Exp [strict(1)]
                    | "jmp" Label
                    | "breq" Label
                    | "brne" Label
                    | "sec"
                    | "clc"
                    | "sen"
                    | "cln"
                    | "sez"
                    | "clz"
                    | "sei"
                    | "cli"
                    | "ses"
                    | "cls"
                    | "sev"
                    | "clv"
                    | "set"
                    | "clt"
                    | "seh"
                    | "clh"
                    | "sleep"
                    | "nop"
                    | "wdr"
                    | "break"
                    | Label ":"
    
    /* 
        Below pragmas will not be implemented for now
        #pragma AVRPART CORE INSTRUCTIONS_NOT_SUPPORTED mnemonic[ operand[,operand] ][:...]
        #pragma AVRPART CORE NEW_INSTRUCTIONS mnemonic[ operand[,operand]][:...]
    */
    syntax Avrpart ::= "avrpart" K K K K K K K

    //TODO: Any of them should be seqstrict?
    // Constant expressions
    syntax Exp ::= Int
                   | "-" Exp [strict]
                   > Exp "*" Exp [left, strict]
                   | Exp "/" Exp [left, strict]
                   | Exp "%" Exp [left, strict]
                   > "!" Exp [strict]
                   | "~" Exp [strict]
                   | Exp "+" Exp [left, strict]
                   | Exp "-" Exp [left, strict]
                   > Exp "<<" Exp [left, strict]
                   | Exp ">>" Exp [left, strict]
                   > Exp "<" Exp [strict]
                   | Exp "<=" Exp [strict]
                   | Exp ">" Exp [strict]
                   | Exp ">=" Exp [strict]
                   > Exp "==" Exp [strict]
                   | Exp "!=" Exp [strict]
                   > Exp "&" Exp [left, strict]
                   > Exp "^" Exp [left, strict]
                   > Exp "|" Exp [left, strict]
                   > Exp "&&" Exp [left, strict]
                   > Exp "||" Exp [left, strict]
                   > Exp "?" Exp ":" Exp [strict]
                   > "(" Exp ")" [bracket]

    // General purpose registers
    syntax GReg ::= Int //"0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "10" | "11" | "12" | "13" | "14" | "15" | "16" | "17"| "18" | "19" | "20" | "21" | "22" | "23" | "24" | "25" | "26" | "27" | "28" | "29" | "30" | "31" 
    
    // IO Registers
    syntax IOReg ::= LowIOReg //load here the device-specific from .inc file - addresses 0-31

    //syntax HighIOReg ::= 
    
    syntax LowIOReg ::= Int

    // Assembly labels
    syntax Label ::= Id
    
    // The program
    syntax Pgm ::= Stmt | Stmt Pgm | Avrpart Pgm

endmodule

//////////////////////////// Configuration //////////////////////////////
module AVRASM
    imports AVRASM-SYNTAX
    imports BITS
    imports UNIT_TEST
    imports MINT

    // Possible states of execution
    syntax State ::= "MAPPING" | "RUNNING" | "FINISHED"| "ERROR"

    /*
    The k cell will bear the code that is executed.

    Cells inside execution manage the program execution. Contains the code and the current information about the execution.

    The clockcycle cell contains the number of execution cycles. Its value is added upon with the execution of instructions.

    Regd and regr contains the values of two registers operands of an instruction, only when it happens.

    The cells registers and pins contains the general purpose registers and the pins of IO, respectively.

    The Status Register cells are:
    ri - Global Interrupt Enable/Disable Flag
    rt - Transfer bit used by BLD and BST instructions
    rh - Half Carry Flag
    rs - N⊕ V, For signed tests
    rv - Two’s complement overflow indicator
    rn - Negative Flag
    rz - Zero Flag
    rc - Carry Flag
   */
    configuration
        <T>
            <k> .K </k>
            
            <avrpart>
                <partname> .K </partname>
                <coreversion> .K </coreversion>
                <flashsize> .K </flashsize>
                <eepromsize> .K </eepromsize>
                <ramsize> .K </ramsize>
                <ramstartaddress> .K </ramstartaddress>
                <partinclude> .K </partinclude>
            </avrpart>
            
            <execution>            
                <init> $PGM:Pgm </init>
                <state> MAPPING </state>
                <stmts> .List </stmts>
                <labels> .Map </labels>
                <pc> 0 </pc>
            </execution>

            <clockcycle> 0 </clockcycle>
            
            <regd> .K </regd>
            <regdv> .K </regdv>
            <regrv> .K </regrv>
           
            <spaddr> 61 </spaddr> 
            
            <dataspace> .Map </dataspace>

            <sreg>
                <ri> false </ri> 
                <rt> false </rt>
                <rh> false </rh>
                <rs> false </rs>
                <rv> false </rv>
                <rn> false </rn>
                <rz> false </rz>
                <rc> false </rc>
            </sreg>
        </T>

//////////////////////////// Rules ///////////////////////////////////
    
    /////////////// Consume AVRPART pragmas //////////////////

    rule <init> avrpart P V F E S SA PI Pr:Pgm => Pr </init>
        <partname> . => P </partname>
        <coreversion> . => V </coreversion>
        <flashsize> . => F </flashsize>
        <eepromsize> . => E </eepromsize>
        <ramsize> . => S </ramsize>
        <ramstartaddress> . => SA </ramstartaddress>
        <partinclude> . => PI </partinclude>

    /////////////// Initial line mapping /////////////////////

    //TODO: Find way to verify if every number in code is lesser than 256 and greater than -256 - E < 256 and E > -257
    //TODO: check if it's necessary to validate the IORegs, if it's not a problem if they're simply Int

    // Maps all the program's instructions. Mapping is having them inside the stmts cell and numbering them.
    rule <init> S:Stmt P:Pgm => P </init>
        <stmts> .List => ListItem(S) </stmts>

    rule <init> S:Stmt => .K </init>
        <stmts> .List => ListItem(S) </stmts>

    rule <init> S:Stmt P:Pgm => P </init>
        <stmts> L:List => L:List ListItem(S) </stmts>

    rule <init> S:Stmt => .K </init>
        <stmts> L:List => L:List ListItem(S) </stmts>
    
    // Find labels and put them in the labels cell
    rule <state> MAPPING </state>
        <init> .K </init>
        <labels> Ls:Map => Ls (L |-> size(Li)) </labels>
        <stmts> Li:List ListItem(L:Label :) </stmts>
        requires notBool (L in keys(Ls))

    rule <state> MAPPING => ERROR </state>// prevent duplicity of labels
        <init> .K </init>
        <labels> _:Map (L:Label |-> Lm:Int) </labels>
        <stmts> Li:List ListItem(L :) </stmts>
        requires Lm =/=Int size(Li)

    // When mapping finishes
    rule <init> .K </init>
        <state> MAPPING => RUNNING </state>

    ///////////////// Program execution /////////////////

    // Fetches an instruction - Step 0
    rule <state> RUNNING </state>
        <k> .K => Stmts[PC] </k>
        <regd> .K </regd>
        <regdv> .K </regdv>
        <regrv> .K </regrv>
        <pc> PC:Int => PC +Int 1 </pc>
        <stmts> Stmts:List </stmts>
    
    // Puts registers into the cells for their values to be retrieved - Step 1
    rule <k> _:RRStmt Rd:GReg, Rr:GReg </k>
        <regd> .K => Rd </regd>
        <regdv> .K => Rd </regdv>
        <regrv> .K => Rr </regrv>
        
    rule <k> _:RIStmt Rd:GReg, Rr:IOReg </k> 
        <regd> .K => Rd </regd>
        <regdv> .K => Rd </regdv>
        <regrv> .K => Rr </regrv>
        
    rule <k> _:IRStmt Rd:IOReg, Rr:GReg </k> 
        <regd> .K => Rd </regd>
        <regdv> .K => Rd </regdv>
        <regrv> .K => Rr </regrv>
        
    rule <k> _:REStmt Rd:GReg, _ </k> 
        <regd> .K => Rd </regd>
        <regdv> .K => Rd </regdv>
        
    rule <k> _:IEStmt Rd:IOReg, _ </k> 
        <regd> .K => Rd </regd>
        <regdv> .K => Rd </regdv>
        
    rule <k> _:RStmt Rd:Int </k> 
        <regd> .K => Rd </regd>
        <regdv> .K => Rd </regdv>

    // Save all registers values after the execution of one instruction - Step 3
    rule <k> .K </k>        
        <regd> RegD:Int => .K </regd>
        <regdv> RegDV:K => .K </regdv>
        <regrv> _ => .K </regrv>
        <dataspace> M:Map => M[RegD <- RegDV] </dataspace>

    // Retrieves values of the two registers - Step 2 TODO: join with the rule above
    rule <regdv> R:Int => Rv </regdv>
        <dataspace>... R |-> Rv:MInt ...</dataspace>
    rule <regrv> R:Int => Rv </regrv>
        <dataspace>... R |-> Rv:MInt ...</dataspace>

    // Label consuming during execution
    rule <k> _:Label : => .K </k> [structural]

    // When execution ends
    rule <k> .K </k> 
        <pc> PC:Int </pc>
        <stmts> Li:List </stmts>
        <state> RUNNING => FINISHED </state>
            requires PC ==Int size(Li)

    /////////// Memory content assurance //////////

    // Int from expression will be turned into MInt
    rule <dataspace>... A:Int |-> (I:Int => toByte(uvalueMInt(toByte(I)))) ...</dataspace>

    // Get MInt from resolution expression
    rule <dataspace>... _ |-> (Res:List => miMInt(Res)) ...</dataspace>

    // Ensures 8-bits numbers in registers at any point in the execution
    rule <dataspace>... _ |-> (mi(N:Int, I:Int) => toByte(uvalueMInt(mi(N, I)))) ...</dataspace>
        requires I >Int 255 orBool I <Int 0


    /////////// Expression evaluation //////////

    syntax KResult ::= Int

    // Arithmetic
    //rule - I:Int => the unary minus is behaving correctly as is (by k framework Int)
    rule I1:Int * I2:Int => I1 *Int I2
    rule I1:Int / I2:Int => I1 /Int I2 requires I2 =/=Int 0
    rule I1:Int % I2:Int => I1 modInt I2 requires I2 =/=Int 0
    rule ! I:Int => 0 requires I =/=Int 0
    rule ! I:Int => 1 requires I ==Int 0
    rule ~ I:Int => ~Int I
    rule I1:Int + I2:Int => I1 +Int I2
    rule I1:Int - I2:Int => I1 -Int I2
    rule I1:Int << I2:Int => I1 <<Int I2
    rule I1:Int >> I2:Int => I1 >>Int I2
    rule I1:Int < I2:Int => BooltoInt(I1 <Int I2)
    rule I1:Int <= I2:Int => BooltoInt(I1 <=Int I2)
    rule I1:Int > I2:Int => BooltoInt(I1 >Int I2)
    rule I1:Int >= I2:Int => BooltoInt(I1 >=Int I2)
    rule I1:Int == I2:Int => BooltoInt(I1 ==Int I2)
    rule I1:Int != I2:Int => BooltoInt(I1 =/=Int I2)
    rule I1:Int & I2:Int => I1 &Int I2
    rule I1:Int ^ I2:Int => I1 xorInt I2
    rule I1:Int | I2:Int => I1 |Int I2
    rule I1:Int && I2:Int => BooltoInt(I1 =/=Int 0 andBool I2 =/=Int 0)
    rule I1:Int || I2:Int => BooltoInt(I1 =/=Int 0 orBool I2 =/=Int 0)
    rule I1:Int ? I2:Int : _:Int => I2 requires I1 =/=Int 0
    rule I1:Int ? _:Int : I3:Int => I3 requires I1 ==Int 0

    /////// Arithmetic and logic instructions ///////////

    // Function used to calculate the N flag of the SREG
    syntax Bool ::= rn(MInt) [function]
    rule rn(R:MInt) => bit(R, 7) [macro]
    
    //ADD - add registers and place result in the first  
    rule <k> add _:GReg, _:GReg => .K </k>
        <regdv> RdV:MInt => addf(RdV, RrV)</regdv>
        <regrv> RrV:MInt </regrv>
        <rh> _ => addrh(RdV, RrV) </rh> 
        <rs> _ => addrs(RdV, RrV) </rs>   
        <rv> _ => addrv(RdV, RrV) </rv>
        <rn> _ => rn(addf(RdV, RrV)) </rn>
        <rz> _ => zeroMInt(addf(RdV, RrV)) </rz> //FIXME: maybe the overflow won't happen here?
        <rc> _ => overflowMInt(uaddMInt(RdV, RrV)) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // Add flags
    syntax MInt ::= addf(MInt, MInt) [function]
    syntax Bool ::= addrh(MInt, MInt) [function]
    syntax Bool ::= addrs(MInt, MInt) [function]
    syntax Bool ::= addrv(MInt, MInt) [function]
    syntax Bool ::= addrvimpl(Bool, Bool, Bool) [function]
    syntax Bool ::= addrhimpl(Bool, Bool, Bool) [function]

    rule addf(RdV:MInt, RrV:MInt) =>
        addMInt(RdV, RrV) [macro]

    // Get bools and result from MInts
    rule addrh(RdV:MInt, RrV:MInt) =>
        addrhimpl(bit(RdV, 3), bit(RrV, 3), bit(addf(RdV, RrV), 3)) [macro]

    // V⊕ N for signed tests
    rule addrs(RdV:MInt, RrV:MInt) =>
        addrv(RdV, RrV) xorBool rn(addf(RdV, RrV)) [macro]

    // Get bools and result from MInts
    rule addrv(RdV:MInt, RrV:MInt) =>
        addrvimpl(bit(RdV, 7), bit(RrV, 7), bit(addf(RdV, RrV), 7)) [macro]
    
    // Rd7 • Rr7 • R7 ¯ + Rd7 ¯ • Rr7 ¯ • R7 - What is the meaning of this???
    rule addrvimpl(Rd7b:Bool, Rr7b:Bool, R7b:Bool) => 
        Rd7b andBool 
        Rr7b andBool
        (notBool R7b) orBool
        (notBool Rd7b) andBool
        (notBool Rr7b) andBool
        R7b [macro]

    // Rd3 • Rr3 + Rr3 • R3 ¯ + R3 ¯ • Rd3
    rule addrhimpl(Rd3b:Bool, Rr3b:Bool, R3b:Bool) => 
        Rd3b andBool
        Rr3b orBool
        Rr3b andBool
        (notBool R3b) orBool
        (notBool R3b) andBool
        Rd3b [macro]

    //SUB - subtract registers and place result in the first
    rule <k> sub _:GReg, _:GReg => .K </k>
        <regdv> RdV:MInt => subf(RdV, RrV) </regdv>
        <regrv> RrV:MInt </regrv>
        <rh> _ => subrh(RdV, RrV) </rh> 
        <rs> _ => subrs(RdV, RrV) </rs>
        <rv> _ => subrv(RdV, RrV) </rv> 
        <rn> _ => rn(subf(RdV, RrV)) </rn>
        <rz> _ => eqMInt(RdV, RrV) </rz> // if result is zero
        <rc> _ => overflowMInt(usubMInt(RdV, RrV)) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SUBI - subtract immediate
    rule <k> subi _:GReg, V:Int => .K </k>
        <regdv> RdV:MInt => subf(RdV, toByte(V)) </regdv>
        <rh> _ => subrh(RdV, toByte(V)) </rh>
        <rs> _ => subrs(RdV, toByte(V)) </rs> 
        <rv> _ => subrv(RdV, toByte(V)) </rv>
        <rn> _ => rn(subf(RdV, toByte(V))) </rn>
        <rz> _ => zeroMInt(subf(RdV, toByte(V))) </rz> // if result is zero
        <rc> _ => overflowMInt(usubMInt(RdV, toByte(V))) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // Sub flags
    syntax MInt ::= subf(MInt, MInt) [function]
    syntax Bool ::= subrh(MInt, MInt) [function]
    syntax Bool ::= subrs(MInt, MInt) [function]
    syntax Bool ::= subrv(MInt, MInt) [function]

    rule subf(RdV:MInt, RrV:MInt) =>
        subMInt(RdV, RrV) [macro]

    // Rd3 ¯ • Rr3 + Rr3 • R3 + R3 • Rd3 ¯
    rule subrh(RdV:MInt, RrV:MInt) =>
        addrhimpl((notBool bit(RdV, 3)), bit(RrV, 3), (notBool bit(subf(RdV, RrV), 3))) [macro]

    // N ⊕ V
    rule subrs(RdV:MInt, RrV:MInt) =>
        rn(subf(RdV, RrV)) xorBool subrv(RdV, RrV) [macro]

    // Rd7 • Rr7 ¯ • R7 ¯ + Rd7 ¯ • Rr7 • R7
    rule subrv(RdV:MInt, RrV:MInt) => 
        addrvimpl(bit(RdV, 7), (notBool bit(RrV, 7)), bit(subf(RdV, RrV), 7)) [macro]

    //INC - increment
    rule <k> inc _:GReg => .K </k>
        <regdv> RdV:MInt => incf(RdV) </regdv>
        <rs> _ => incrs(RdV) </rs> 
        <rv> _ => incrv(RdV) </rv> 
        <rn> _ => rn(incf(RdV)) </rn>
        <rz> _ => zeroMInt(incf(RdV)) </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // Inc auxiliary functions
    syntax MInt ::= incf(MInt) [function]
    syntax Bool ::= incrs(MInt) [function]
    syntax Bool ::= incrv(MInt) [function]

    rule incf(RdV:MInt) =>
        addf(RdV, toByte(1)) [macro]

    // N ⊕ V
    rule incrs(RdV:MInt) =>
        rn(incf(RdV)) xorBool incrv(RdV) [macro]

    // R7 • R6 ¯ • R5 ¯ • R4 ¯ • R3 ¯ • R2 ¯ • R1 ¯ • R0 ¯
    rule incrv(RdV:MInt) =>
       eqMInt(RdV, toByte(127)) [macro]

    //DEC - decrement
    rule <k> dec _:GReg => .K </k>
        <regdv>... RdV:MInt => decf(RdV) ...</regdv>
        <rs> _ => decrs(RdV) </rs> 
        <rv> _ => decrv(RdV) </rv> 
        <rn> _ => rn(decf(RdV)) </rn>
        <rz> _ => zeroMInt(decf(RdV)) </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
    
    // Dec flags
    syntax MInt ::= decf(MInt) [function]
    syntax Bool ::= decrs(MInt) [function]
    syntax Bool ::= decrv(MInt) [function]

    rule decf(RdV:MInt) =>
        subf(RdV, toByte(1)) [macro]

    // N ⊕ V
    rule decrs(RdV:MInt) =>
        rn(decf(RdV)) xorBool decrv(RdV) [macro]

    // R7 ¯ • R6 • R5 • R4 • R3 • R2 • R1 • R0
    rule decrv(RdV:MInt) =>
        eqMInt(RdV, toByte(128)) [macro]

    //EOR - exclusive or
    rule <k> eor _:GReg, _:GReg => .K </k>
        <regdv> RdV:MInt => eorf(RdV, RrV) </regdv>
        <regrv> RrV:MInt </regrv>
        <rs> _ => rn(eorf(RdV, RrV)) xorBool false </rs> // N ⊕ V
        <rv> _ => false </rv>
        <rn> _ => rn(eorf(RdV, RrV)) </rn>
        <rz> _ => zeroMInt(eorf(RdV, RrV)) </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle> 
   
    // Eor
    syntax MInt ::= eorf(MInt, MInt) [function]
   
    rule eorf(RdV:MInt, RrV:MInt) =>
       xorMInt(RdV, RrV) [macro]

    // CLR - Clear register. As it is a rewrite to EOR, the same flags modified in EOR will be modified here.
    rule clr Rd:GReg => eor Rd, Rd [macro]

    //SER - set register. No flags modified
    rule ser Rd:GReg => ldi Rd, 255 [macro]
    
    /////////////// Branch Instructions /////////////

    //CP - compare registers
    rule <k> cp _:GReg, _:GReg => .K </k>
        <regdv> RdV:MInt </regdv>
        <regrv> RrV:MInt </regrv>
        <rh> _ => subrh(RdV, RrV) </rh> 
        <rs> _ => subrs(RdV, RrV) </rs>
        <rv> _ => subrv(RdV, RrV) </rv> 
        <rn> _ => rn(subf(RdV, RrV)) </rn>
        <rz> _ => zeroMInt(subMInt(RdV, RrV)) </rz> // if result is zero
        <rc> _ => ultMInt(RdV, RrV) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle> 

    //JMP - jump to label
    rule <k> jmp La:Label => .K </k>
        <pc> _ => Line </pc>
        <labels>... La |-> Line:Int ...</labels>
        <clockcycle> C:Int => C +Int 3 </clockcycle>

    //BREQ - branch if equal
    rule <k> breq La:Label => .K </k>
        <pc> _ => Line </pc>
        <labels>... La |-> Line:Int ...</labels>
        <rz> true </rz>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    rule <k> breq _ => .K </k>
        <rz> false </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //BRNE - branch if not equal
    rule <k> brne La:Label => .K  </k>
        <pc> _ => Line </pc>
        <labels>... La |-> Line:Int ...</labels>
        <rz> false </rz>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    rule <k> brne _ => .K </k>
        <rz> true </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    /////////////// Data Transfer //////////////////

    //MOV - copy register
    rule <k> mov _:GReg, _:GReg => .K </k>
        <regdv> _ => RrV </regdv>
        <regrv> RrV:MInt </regrv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //LDI - load immediate
    rule <k> ldi _:GReg, V:Int => .K </k> 
        <regdv> _ => toByte(V) </regdv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
   
    //IN - read input into register
    rule <k> in _:GReg, _:IOReg => .K </k>
        <regdv> _  => IorV </regdv>
        <regrv> IorV:MInt </regrv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
   
    //OUT - configure pins for in or out
    rule <k> out _:IOReg, _:GReg => .K </k> 
        <regdv> _ => RrV </regdv>
        <regrv> RrV:MInt </regrv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //PUSH - stores register value on the stack 
    //TODO: handle overflows in RAM boundaries
    rule <k> push _:GReg => . </k>
        <spaddr> SPA:Int </spaddr>
        <dataspace> M:Map (SPA |-> MI:MInt) => M ((uvalueMInt(MI) |-> Rv) (SPA |-> decf(MI))) </dataspace>
        <regdv> Rv:MInt </regdv>
        <clockcycle> C:Int => C +Int 2 </clockcycle>
  
    //POP - loads register with byte from the stack
    // TODO: handle overflows in RAM boundaries
    rule <k> pop _:GReg => . </k>
        <spaddr> SPA:Int </spaddr>
        <dataspace> M:Map (SPA |-> MI:MInt) (uvalueMInt(incf(MI)) |-> PV:MInt) => M (SPA |-> incf(MI)) (uvalueMInt(incf(MI)) |-> PV:MInt) </dataspace>
        <regdv> _ => PV </regdv>
        <clockcycle> C:Int => C +Int 2 </clockcycle>
 
    ///////// Bit and Bit-test instructions /////////

    //ROR - rotate right through carry
    rule <k> ror _:GReg => .K </k>
        <regdv> Rdv:MInt => rorf(Rdv, Cv) </regdv>
        <rs> _ => rn(rorf(Rdv, Cv)) xorBool rorrv(Rdv, Cv) </rs> //N ⊕ V
        <rv> _ => rorrv(Rdv, Cv) </rv> //N ⊕ C
        <rn> _ => rn(rorf(Rdv, Cv)) </rn>
        <rz> _ => zeroMInt(rorf(Rdv, Cv)) </rz>
        <rc> Cv:Bool => rorrc(Rdv) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // ROR auxiliary functions
    syntax MInt ::= rorf(MInt, Bool) [function]
    syntax Bool ::= rorrv(MInt, Bool) [function]
    syntax Bool ::= rorrc(MInt) [function]

    rule rorf(Rdv:MInt, Cv:Bool) => 
        orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)) [macro]

    rule rorrv(Rdv:MInt, Cv:Bool) => 
        rn(rorf(Rdv, Cv)) xorBool rorrc(Rdv) [macro]

    rule rorrc(Rdv:MInt) => 
        bit(Rdv, 0) [macro]


    //ASR - arithmetic shift right
    rule <k> asr _:GReg => .K </k>
        <regdv> RdV:MInt => asrf(RdV) </regdv>
        <rs> _ => rn(asrf(RdV)) xorBool asrrv(RdV) </rs>//N ⊕ V
        <rv> _ => asrrv(RdV) </rv> //N ⊕ C
        <rn> _ => rn(asrf(RdV)) </rn>
        <rz> _ => zeroMInt(asrf(RdV)) </rz>
        <rc> _ => rorrc(RdV) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //ASR auxiliary functions
    syntax MInt ::= asrf(MInt) [function]
    syntax Bool ::= asrrv(MInt) [function]

    rule asrf(RdV:MInt) => 
        sshrMInt(RdV, 1) [macro]

    rule asrrv(RdV:MInt) =>
        rn(asrf(RdV)) xorBool rorrc(RdV) [macro]
        

    //SWAP - swap nibbles
    rule <k> swap _:GReg => .K </k>
        <regdv> RdV:MInt => orMInt(shlMInt(RdV, 4), ashrMInt(RdV, 4)) </regdv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //BSET - set SREG flag
    rule <k> bset S:Int => sec </k>
        requires S ==Int 0 [structural]
        
    rule <k> bset S:Int => sez </k> 
        requires S ==Int 1 [structural]
        
    rule <k> bset S:Int => sen </k> 
        requires S ==Int 2 [structural]
        
    rule <k> bset S:Int => sev </k> 
        requires S ==Int 3 [structural]
        
    rule <k> bset S:Int => ses </k> 
        requires S ==Int 4 [structural]
        
    rule <k> bset S:Int => seh </k> 
        requires S ==Int 5 [structural]
        
    rule <k> bset S:Int => set </k>
        requires S ==Int 6 [structural]
        
    rule <k> bset S:Int => sei </k> 
        requires S ==Int 7 [structural]

    //BCLR - clear SREG flag
    rule <k> bclr S:Int => clc </k> 
        requires S ==Int 0 [structural]
        
    rule <k> bclr S:Int => clz </k> 
        requires S ==Int 1 [structural]
        
    rule <k> bclr S:Int => cln </k> 
        requires S ==Int 2 [structural]
        
    rule <k> bclr S:Int => clv </k> 
        requires S ==Int 3 [structural]
        
    rule <k> bclr S:Int => cls </k> 
        requires S ==Int 4 [structural]
        
    rule <k> bclr S:Int => clh </k> 
        requires S ==Int 5 [structural]
        
    rule <k> bclr S:Int => clt </k> 
        requires S ==Int 6 [structural]
        
    rule <k> bclr S:Int => cli </k> 
        requires S ==Int 7 [structural]
        
    //SBI P,b - set bit in I/O register
    rule <k> sbi _:LowIOReg, B:Int => .K </k>
        <regdv> Iorv:MInt => setf(Iorv, B) </regdv>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    //CBI P,b - clear bit in I/O register
    rule <k> cbi _:LowIOReg, B:Int => .K </k>
        <regdv> Iorv:MInt => clrf(Iorv, B) </regdv>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    //BST Rr,b - bit store from register to T
    rule <k> bst _:GReg, B:Int => .K </k>
        <regdv> Rdv:MInt </regdv>
        <rt> _ => bit(Rdv, B) </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //BLD Rd,b - Bit load from register to T
    rule <k> bld _:GReg, B:Int => .K </k>
        <regdv> Rdv:MInt => setf(Rdv, B) </regdv>
        <rt> true </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    rule <k> bld _:GReg, B:Int => .K </k>
        <regdv> Rdv:MInt => clrf(Rdv, B) </regdv>
        <rt> false </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEC - Set carry flag
    rule <k> sec => .K </k>
        <rc> _ => true </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLC - Clear carry flag
    rule <k> clc => .K </k>
        <rc> _ => false </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEN - Set negative flag
    rule <k> sen => .K </k>
        <rn> _ => true </rn>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLN - Clear negative flag
    rule <k> cln => .K </k>
        <rn> _ => false </rn>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEZ - Set zero flag
    rule <k> sez => .K </k>
        <rz> _ => true </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLZ - Clear zero flag
    rule <k> clz => .K </k>
        <rz> _ => false </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEI - Set interrupt flag
    rule <k> sei => .K </k>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
        <ri> _ => true </ri>

    //CLI - Clear interrupt flag
    rule <k> cli => .K </k>
        <ri> _ => false </ri>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SES - Set signed flag
    rule <k> ses => .K </k>
        <rs> _ => true </rs>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLN - Clear signed flag
    rule <k> cls => .K </k>
        <rs> _ => false </rs>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEV - Set overflow flag
    rule <k> sev => .K </k>
        <rv> _ => true </rv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLV - Clear overflow flag
    rule <k> clv => .K </k>
        <rv> _ => false </rv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SET - Set T-flag
    rule <k> set => .K </k>
        <rt> _ => true </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLT - Clear T-flag
    rule <k> clt => .K </k>
        <rt> _ => false </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEH - Set half carry flag
    rule <k> seh => .K </k>
        <rh> _ => true </rh>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLH - Clear half carry flag
    rule <k> clh => .K </k>
        <rh> _ => false </rh>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // MCU control

    //SLEEP - sleep
    rule <k> sleep => .K </k>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //NOP - no operation
    rule <k> nop => .K </k>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
    
    //WDR - watchdog reset
    rule <k> wdr => .K </k>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
    
    //BREAK - for on-chip debug
    rule <k> break => .K </k>

endmodule

