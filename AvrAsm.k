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

    // Assembly instructions
    syntax Stmt ::= RRStmt Reg "," Reg
                    | "in" Reg "," IOReg
                    | "out" IOReg "," Reg
                    | "push" Reg
                    | "pop" Reg
                    | "ldi" Reg "," Exp [strict(2)]
                    | "subi" Reg "," Exp [strict(2)]
                    | "bst" Reg "," Exp [strict(2)]
                    | "bld" Reg "," Exp [strict(2)]
                    | "sbi" IOReg "," Exp [strict(2)]
                    | "cbi" IOReg "," Exp [strict(2)]
                    | "inc" Reg
                    | "dec" Reg 
                    | "clr" Reg 
                    | "ser" Reg 
                    | "ror" Reg 
                    | "asr" Reg 
                    | "swap" Reg 
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
    syntax Reg ::= "R0" | "R1" | "R2" | "R3" | "R4" | "R5" | "R6" | "R7" | "R8" | "R9" | "R10" | "R11" | "R12"
                | "R13" | "R14" | "R15" | "R16" | "R17" | "R18" | "R19" | "R20" | "R21" | "R22" | "R23" | "R24"
                | "R25" | "R26" | "R27" | "R28" | "R29" | "R30" | "R31" 
    
    // IO Registers
    syntax IOReg ::= LowIOReg //load here the device-specific from .inc file - addresses 0-31

    //syntax HighIOReg ::= 
    
    syntax LowIOReg ::=  "PORTA" | "PORTB" | "PORTC" | "PORTD" | "DDRA" | "DDRB" | "DDRC" | "DDRD" //load here the device-specific from .inc file - adresses 32-63

    // Assembly labels
    syntax Label ::= Id
    
    // The program
    syntax Pgm ::= Stmt | Stmt Pgm

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
            
            <execution>            
                <init> $PGM:Pgm </init>
                <state> MAPPING </state>
                <stmts> .List </stmts>
                <labels> .Map </labels>
                <pc> 0 </pc>
            </execution>

            <clockcycle> 0 </clockcycle>
            
            <regd> .K </regd>
            <regr> .K </regr>
           
            <spointer> 0 </spointer> 
            <stack> .List </stack>
    
            <registers> 
                R0 |-> $mi(8, 0) R1 |-> $mi(8, 0) R2 |-> $mi(8, 0) R3 |-> $mi(8, 0) R4 |-> $mi(8, 0) R5 |-> $mi(8, 0) R6 |-> $mi(8, 0) R7 |-> $mi(8, 0) R8 |-> $mi(8, 0) R9 |-> $mi(8, 0) R10 |-> $mi(8, 0) R11 |-> $mi(8, 0) R12 |-> $mi(8, 0) R13 |-> $mi(8, 0) R14 |-> $mi(8, 0) R15 |-> $mi(8, 0) R16 |-> $mi(8, 0) R17 |-> $mi(8, 0) R18 |-> $mi(8, 0) R19 |-> $mi(8, 0) R20 |-> $mi(8, 0) R21 |-> $mi(8, 0) R22 |-> $mi(8, 0) R23 |-> $mi(8, 0) R24 |-> $mi(8, 0) R25 |-> $mi(8, 0) R26 |-> $mi(8, 0) R27 |-> $mi(8, 0) R28 |-> $mi(8, 0) R29 |-> $mi(8, 0) R30 |-> $mi(8, 0) R31 |-> $mi(8, 0) 
            </registers>
            <pins>
                PORTA |-> $mi(8, 0) PORTB |-> $mi(8, 0) PORTC |-> $mi(8, 0) PORTD |-> $mi(8, 0) DDRA |-> $mi(8, 0) DDRB |-> $mi(8, 0) DDRC |-> $mi(8, 0) DDRD |-> $mi(8, 0) 
            </pins>
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
    
    /////////////// Initial line mapping /////////////////////

    // Syntax for stmt list
    syntax IdxStmt ::= "[" Int "," Stmt "]"

    //TODO: Find way to verify if every number in code is lesser than 256 and greater than -256 - E < 256 and E > -257
    
    // Maps all the program's instructions. Mapping is having them inside the stmts cell and numbering them.
    rule <init> S:Stmt P:Pgm => P </init>
        <stmts> .List => ListItem([0, S]) </stmts>

    rule <init> S:Stmt => .K </init>
        <stmts> .List => ListItem([0, S]) </stmts>

    rule <init> S:Stmt P:Pgm => P </init>
        <stmts>... ListItem([I:Int, T:Stmt]) => ListItem([I, T]) ListItem([I +Int 1, S]) </stmts>

    rule <init> S:Stmt => .K </init>
        <stmts>... ListItem([I:Int, T:Stmt]) => ListItem([I, T]) ListItem([I +Int 1, S]) </stmts>
    
    // Find labels and put them in the labels cell
    rule <state> MAPPING </state>
        <init> .K </init>
        <labels> Ls:Map (. => L |-> I) </labels>
        <stmts>... ListItem([I:Int, L:Label :]) ...</stmts>
        requires notBool (L in keys(Ls))

    rule <state> MAPPING => ERROR </state>// prevent duplicity of labels
        <init> .K </init>
        <labels> _:Map (L:Label |-> Lm:Int) </labels>
        <stmts>... ListItem([Ln:Int, L :]) ...</stmts>
        requires Lm =/=Int Ln 

    // When mapping finishes
    rule <init> .K </init>
        <state> MAPPING => RUNNING </state>

    ///////////////// Program execution /////////////////

    // Instruction fetching
    rule <state> RUNNING </state>
        <k> .K => S </k>
        <regd> _ => .K </regd>
        <regr> _ => .K </regr>
        <pc> PC:Int => PC +Int 1 </pc>
        <stmts>... ListItem([PC, S:Stmt]) ...</stmts>
    
    // Puts registers into the cells for their values to be retrieved
    rule <k> _ Rd:Reg, Rr:Reg </k> 
        <regd> .K => Rd </regd>
        <regr> .K => Rr </regr>
        
    // Fetches values of the two registers
    rule <regd> R:Reg => Rv </regd>
        <registers>... R |-> Rv:MInt ...</registers>
    rule <regr> R:Reg => Rv </regr>
        <registers>... R |-> Rv:MInt ...</registers>

    // Label consuming during execution
    rule <k> _:Label : => .K </k> [structural]

    // When execution ends
    rule <k> .K </k> 
        <pc> PC:Int </pc>
        <stmts>... ListItem([I:Int, _]) </stmts>
        <state> RUNNING => FINISHED </state>
            requires PC ==Int (I +Int 1)

    /////////// Registers content assurance //////////

    // Int from expression will be turned into MInt
    rule <registers>... _ |-> (I:Int => toByte(uvalueMInt(toByte(I)))) ...</registers>
    rule <pins>... _ |-> (I:Int => toByte(uvalueMInt(toByte(I)))) ...</pins> 

    // Get MInt from resolution expression
    rule <registers>... _ |-> (Res:MyList => miMInt(Res)) ...</registers>

    // Ensures 8-bits numbers in registers at any point in the execution
    rule <registers>... _ |-> ($mi(N:Int, I:Int) => toByte(uvalueMInt($mi(N, I)))) ...</registers>
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
    rule <k> add Rd:Reg, _:Reg => .K </k>
        <regd> RdV:MInt </regd>
        <regr> RrV:MInt </regr>
        <registers>... (Rd |-> (_ => add(RdV, RrV)))  ...</registers>
        <rh> _ => addrh(RdV, RrV) </rh> 
        <rs> _ => addrs(RdV, RrV) </rs>   
        <rv> _ => addrv(RdV, RrV) </rv>
        <rn> _ => rn(add(RdV, RrV)) </rn>
        <rz> _ => zeroMInt(add(RdV, RrV)) </rz> //FIXME: maybe the overflow won't happen here?
        <rc> _ => overflowMInt(uaddMInt(RdV, RrV)) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // Add flags
    syntax MInt ::= add(MInt, MInt) [function]
    syntax Bool ::= addrh(MInt, MInt) [function]
    syntax Bool ::= addrs(MInt, MInt) [function]
    syntax Bool ::= addrv(MInt, MInt) [function]
    syntax Bool ::= addrvimpl(Bool, Bool, Bool) [function]
    syntax Bool ::= addrhimpl(Bool, Bool, Bool) [function]

    rule add(RdV:MInt, RrV:MInt) =>
        addMInt(RdV, RrV) [macro]

    // Get bools and result from MInts
    rule addrh(RdV:MInt, RrV:MInt) =>
        addrhimpl(bit(RdV, 3), bit(RrV, 3), bit(add(RdV, RrV), 3)) [macro]

    // V⊕ N for signed tests
    rule addrs(RdV:MInt, RrV:MInt) =>
        addrv(RdV, RrV) xorBool rn(add(RdV, RrV)) [macro]

    // Get bools and result from MInts
    rule addrv(RdV:MInt, RrV:MInt) =>
        addrvimpl(bit(RdV, 7), bit(RrV, 7), bit(add(RdV, RrV), 7)) [macro]
    
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
    rule <k> sub Rd:Reg, _:Reg => .K </k>
        <regd> RdV:MInt </regd>
        <regr> RrV:MInt </regr>
        <registers>... Rd |-> (_ => sub(RdV, RrV)) ...</registers>
        <rh> _ => subrh(RdV, RrV) </rh> 
        <rs> _ => subrs(RdV, RrV) </rs>
        <rv> _ => subrv(RdV, RrV) </rv> 
        <rn> _ => rn(sub(RdV, RrV)) </rn>
        <rz> _ => eqMInt(RdV, RrV) </rz> // if result is zero
        <rc> _ => overflowMInt(usubMInt(RdV, RrV)) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SUBI - subtract immediate
    rule <k> subi Rd:Reg, V:Int => .K </k>
        <registers>... Rd |-> (RdV:MInt => sub(RdV, toByte(V))) ...</registers>
        <rh> _ => subrh(RdV, toByte(V)) </rh>
        <rs> _ => subrs(RdV, toByte(V)) </rs> 
        <rv> _ => subrv(RdV, toByte(V)) </rv>
        <rn> _ => rn(sub(RdV, toByte(V))) </rn>
        <rz> _ => zeroMInt(sub(RdV, toByte(V))) </rz> // if result is zero
        <rc> _ => overflowMInt(usubMInt(RdV, toByte(V))) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // Sub flags
    syntax MInt ::= sub(MInt, MInt) [function]
    syntax Bool ::= subrh(MInt, MInt) [function]
    syntax Bool ::= subrs(MInt, MInt) [function]
    syntax Bool ::= subrv(MInt, MInt) [function]

    rule sub(RdV:MInt, RrV:MInt) =>
        subMInt(RdV, RrV) [macro]

    // Rd3 ¯ • Rr3 + Rr3 • R3 + R3 • Rd3 ¯
    rule subrh(RdV:MInt, RrV:MInt) =>
        addrhimpl((notBool bit(RdV, 3)), bit(RrV, 3), (notBool bit(sub(RdV, RrV), 3))) [macro]

    // N ⊕ V
    rule subrs(RdV:MInt, RrV:MInt) =>
        rn(sub(RdV, RrV)) xorBool subrv(RdV, RrV) [macro]

    // Rd7 • Rr7 ¯ • R7 ¯ + Rd7 ¯ • Rr7 • R7
    rule subrv(RdV:MInt, RrV:MInt) => 
        addrvimpl(bit(RdV, 7), (notBool bit(RrV, 7)), bit(sub(RdV, RrV), 7)) [macro]

    //INC - increment
    rule <k> inc Rd:Reg => .K </k>
        <registers>... Rd |-> (RdV:MInt => inc(RdV)) ...</registers>
        <rs> _ => incrs(RdV) </rs> 
        <rv> _ => incrv(RdV) </rv> 
        <rn> _ => rn(inc(RdV)) </rn>
        <rz> _ => zeroMInt(inc(RdV)) </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // Inc auxiliary functions
    syntax MInt ::= inc(MInt) [function]
    syntax Bool ::= incrs(MInt) [function]
    syntax Bool ::= incrv(MInt) [function]

    rule inc(RdV:MInt) =>
        add(RdV, toByte(1)) [macro]

    // N ⊕ V
    rule incrs(RdV:MInt) =>
        rn(inc(RdV)) xorBool incrv(RdV) [macro]

    // R7 • R6 ¯ • R5 ¯ • R4 ¯ • R3 ¯ • R2 ¯ • R1 ¯ • R0 ¯
    rule incrv(RdV:MInt) =>
       eqMInt(RdV, toByte(127)) [macro]

    //DEC - decrement
    rule <k> dec Rd:Reg => .K </k>
        <registers>... Rd |-> (RdV:MInt => dec(RdV)) ...</registers>
        <rs> _ => decrs(RdV) </rs> 
        <rv> _ => decrv(RdV) </rv> 
        <rn> _ => rn(dec(RdV)) </rn>
        <rz> _ => zeroMInt(dec(RdV)) </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
    
    // Dec flags
    syntax MInt ::= dec(MInt) [function]
    syntax Bool ::= decrs(MInt) [function]
    syntax Bool ::= decrv(MInt) [function]

    rule dec(RdV:MInt) =>
        sub(RdV, toByte(1)) [macro]

    // N ⊕ V
    rule decrs(RdV:MInt) =>
        rn(dec(RdV)) xorBool decrv(RdV) [macro]

    // R7 ¯ • R6 • R5 • R4 • R3 • R2 • R1 • R0
    rule decrv(RdV:MInt) =>
        eqMInt(RdV, toByte(128)) [macro]

    //EOR - exclusive or
    rule <k> eor Rd:Reg, _:Reg => .K </k>
        <regd> RdV:MInt </regd>
        <regr> RrV:MInt </regr>
        <registers>... Rd |-> (_ => eor(RdV, RrV)) ...</registers>
        <rs> _ => rn(eor(RdV, RrV)) xorBool false </rs> // N ⊕ V
        <rv> _ => false </rv>
        <rn> _ => rn(eor(RdV, RrV)) </rn>
        <rz> _ => zeroMInt(eor(RdV, RrV)) </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle> 
   
    // Eor
    syntax MInt ::= eor(MInt, MInt) [function]
   
    rule eor(RdV:MInt, RrV:MInt) =>
       xorMInt(RdV, RrV) [macro]

    // CLR - Clear register. As it is a rewrite to EOR, the same flags modified in EOR will be modified here.
    rule clr Rd:Reg => eor Rd, Rd [macro]

    //SER - set register. No flags set
    rule ser Rd:Reg => ldi Rd, 255 [macro]
    
    /////////////// Branch Instructions /////////////

    //CP - compare registers
    rule <k> cp _:Reg, _:Reg => .K </k>
        <regd> RdV:MInt </regd>
        <regr> RrV:MInt </regr>
        <rh> _ => subrh(RdV, RrV) </rh> 
        <rs> _ => subrs(RdV, RrV) </rs>
        <rv> _ => subrv(RdV, RrV) </rv> 
        <rn> _ => rn(sub(RdV, RrV)) </rn>
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
    rule <k> mov Rd:Reg, _:Reg => .K </k>
        <regr> RrV:MInt </regr>
        <registers>... Rd |-> (_ => RrV) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //LDI - load immediate
    rule <k> ldi Rd:Reg, V:Int => .K </k> 
        <registers>... Rd |-> (_ => V) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
   
    //IN - read input into register
    rule <k> in Rd:Reg, Ior:IOReg => .K </k>
        <pins>... (Ior |-> IorV:MInt) ...</pins> 
        <registers>... Rd |-> (_ => IorV) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
   
    //OUT - configure pins for in or out
    rule <k> out Ior:IOReg, Rr:Reg => .K </k> 
        <registers>...  (Rr |-> RrV:MInt) ...</registers>
        <pins>... Ior |-> (_ => RrV) ...</pins>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //PUSH - stores register value on the stack
    rule <k> push Rr:Reg => . </k>
        <spointer> SP:Int => SP -Int 1 </spointer>
        <stack>... . => ListItem(RrV:MInt) </stack>
        <registers>... Rr |-> RrV ...</registers>
        <clockcycle> C:Int => C +Int 2 </clockcycle>
  
    //POP - loads register with byte from the stack
    rule <k> pop Rd:Reg => . </k>
        <spointer> SP:Int => SP +Int 1 </spointer>
        <stack>... ListItem(I:MInt) => .  </stack>
        <registers>... Rd |-> (_ => I) ...</registers>
        <clockcycle> C:Int => C +Int 2 </clockcycle>
 
    rule <k> pop Rd:Reg => . </k>
        <spointer> SP:Int => SP +Int 1 </spointer>
        <stack> .List </stack>
        <registers>... Rd |-> (_ => toByte(0)) ...</registers>
        <clockcycle> C:Int => C +Int 2 </clockcycle>
 
    ///////// Bit and Bit-test instructions /////////

    //ROR - rotate right through carry
    rule <k> ror Rd:Reg => .K </k>
        <registers>... Rd |-> (Rdv:MInt => ror(Rdv, Cv)) ...</registers>
        <rs> _ => rn(ror(Rdv, Cv)) xorBool rorrv(Rdv, Cv) </rs> //N ⊕ V
        <rv> _ => rorrv(Rdv, Cv) </rv> //N ⊕ C
        <rn> _ => rn(ror(Rdv, Cv)) </rn>
        <rz> _ => zeroMInt(ror(Rdv, Cv)) </rz>
        <rc> Cv:Bool => rorrc(Rdv) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // ROR auxiliary functions
    syntax MInt ::= ror(MInt, Bool) [function]
    syntax Bool ::= rorrv(MInt, Bool) [function]
    syntax Bool ::= rorrc(MInt) [function]

    rule ror(Rdv:MInt, Cv:Bool) => 
        orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)) [macro]

    rule rorrv(Rdv:MInt, Cv:Bool) => 
        rn(ror(Rdv, Cv)) xorBool rorrc(Rdv) [macro]

    rule rorrc(Rdv:MInt) => 
        bit(Rdv, 0) [macro]


    //ASR - arithmetic shift right
    rule <k> asr Rd:Reg => .K </k>
        <registers>... Rd |-> (RdV:MInt => asr(RdV)) ...</registers>
        <rs> _ => rn(asr(RdV)) xorBool asrrv(RdV) </rs>//N ⊕ V
        <rv> _ => asrrv(RdV) </rv> //N ⊕ C
        <rn> _ => rn(asr(RdV)) </rn>
        <rz> _ => zeroMInt(asr(RdV)) </rz>
        <rc> _ => rorrc(RdV) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //ASR auxiliary functions
    syntax MInt ::= asr(MInt) [function]
    syntax Bool ::= asrrv(MInt) [function]

    rule asr(RdV:MInt) => 
        sshrMInt(RdV, 1) [macro]

    rule asrrv(RdV) =>
        rn(asr(RdV)) xorBool rorrc(RdV) [macro]
        

    //SWAP - swap nibbles
    rule <k> swap Rd:Reg => .K </k>
        <registers>...  Rd |-> (Rdv:MInt => orMInt(shlMInt(Rdv, 4), ashrMInt(Rdv, 4))) ...</registers>
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
    rule <k> sbi Ior:LowIOReg, B:Int => .K </k>
        <pins>... Ior |-> (Iorv:MInt => set(Iorv, B)) ...</pins>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    //CBI P,b - clear bit in I/O register
    rule <k> cbi Ior:LowIOReg, B:Int => .K </k>
        <pins>... Ior |-> (Iorv:MInt => clr(Iorv, B)) ...</pins>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    //BST Rr,b - bit store from register to T
    rule <k> bst Rd:Reg, B:Int => .K </k>
        <registers>... Rd |-> Rdv:MInt ...</registers>
        <rt> _ => bit(Rdv, B) </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //BLD Rd,b - Bit load from register to T
    rule <k> bld Rd:Reg, B:Int => .K </k>
        <registers>... Rd |-> (Rdv:MInt => set(Rdv, B)) ...</registers>
        <rt> true </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    rule <k> bld Rd:Reg, B:Int => .K </k>
        <registers>... Rd |-> (Rdv:MInt => clr(Rdv, B)) ...</registers>
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

