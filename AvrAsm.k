require "bits.k"
require "unittest.k"

module AVRASM-SYNTAX
    imports UNIT_TEST-SYNTAX

    syntax Stmt ::= "add" Reg "," Reg
                    | "mov" Reg "," Reg
                    | "ldi" Reg "," Exp [strict(2)]
                    | "sub" Reg "," Reg
                    | "subi" Reg "," Exp [strict(2)]
                    | "inc" Reg
                    | "dec" Reg
                    | "clr" Reg
                    | "ser" Reg
                    | "sbi" LowIOReg "," Exp
                    | "cbi" LowIOReg "," Exp
                    | "ror" Reg
                    | "asr" Reg
                    | "swap" Reg
                    | "bset" Int
                    | "bclr" Int
                    | "bst" Reg "," Exp
                    | "bld" Reg "," Exp
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
                    | "in" Reg "," IOReg
                    | "out" IOReg "," Reg
                    | "jmp" Label
                    | "breq" Label
                    | "brne" Label
                    | "cp" Reg "," Reg
                    | "sleep"
                    | "nop"
                    | "wdr"
                    | "break"
                    | Label ":"

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

    syntax Reg ::= "R0" | "R1" | "R2" | "R3" | "R4" | "R5" | "R6" | "R7" | "R8" | "R9" | "R10" | "R11" | "R12" | "R13" | "R14" | "R15" | "R16" | "R17" | "R18" | "R19" | "R20" | "R21" | "R22" | "R23" | "R24" | "R25" | "R26" | "R27" | "R28" | "R29" | "R30" | "R31" 

    syntax IOReg ::= LowIOReg //load here the device-specific from .inc file - addresses 0-31

  //syntax HighIOReg ::= 
    syntax LowIOReg ::=  "PORTA" | "PORTB" | "PORTC" | "PORTD" | "DDRA" | "DDRB" | "DDRC" | "DDRD" //load here the device-specific from .inc file - adresses 32-63

    syntax Label ::= Id

    syntax Pgm ::= Stmt | Stmt Pgm

endmodule

//////////////////////////// Configuration //////////////////////////////
module AVRASM
    imports AVRASM-SYNTAX
    imports BITS
    imports UNIT_TEST
    imports MINT

    syntax State ::= "MAPPING" | "RUNNING" | "FINISHED"| "ERROR"

    configuration
        <T>
            <k> .K </k>
            <pc> 0 </pc>
            
            <init> $PGM:Pgm </init>
            <state> MAPPING </state>
            <stmts> .List </stmts>
            <labels> .Map </labels>
            <clockcycle> 0 </clockcycle>

            <registers> 
                R0 |-> toByte(0) R1 |-> toByte(0) R2 |-> toByte(0) R3 |-> toByte(0) R4 |-> toByte(0) R5 |-> toByte(0) R6 |-> toByte(0) R7 |-> toByte(0) R8 |-> toByte(0) R9 |-> toByte(0) R10 |-> toByte(0) R11 |-> toByte(0) R12 |-> toByte(0) R13 |-> toByte(0) R14 |-> toByte(0) R15 |-> toByte(0) R16 |-> toByte(0) R17 |-> toByte(0) R18 |-> toByte(0) R19 |-> toByte(0) R20 |-> toByte(0) R21 |-> toByte(0) R22 |-> toByte(0) R23 |-> toByte(0) R24 |-> toByte(0) R25 |-> toByte(0) R26 |-> toByte(0) R27 |-> toByte(0) R28 |-> toByte(0) R29 |-> toByte(0) R30 |-> toByte(0) R31 |-> toByte(0)
            </registers>
            <pins>
                PORTA |-> toByte(0) PORTB |-> toByte(0) PORTC |-> toByte(0) PORTD |-> toByte(0) DDRA |-> toByte(0) DDRB |-> toByte(0) DDRC |-> toByte(0) DDRD |-> toByte(0) 
            </pins>
            <sreg>
                <ri> false </ri> // Global Interrupt Enable/Disable Flag
                <rt> false </rt> // Transfer bit used by BLD and BST instructions
                <rh> false </rh> // Half Carry Flag
                <rs> false </rs> // N⊕ V, For signed tests
                <rv> false </rv> // Two’s complement overflow indicator
                <rn> false </rn> // Negative Flag
                <rz> false </rz> // Zero Flag
                <rc> false </rc> // Carry Flag
            </sreg>
        </T>

//////////////////////////// Rules ///////////////////////////////////
    
    /////////// Initial line mapping /////////////

    // Syntax for Stmt list
    syntax IdxStmt ::= "[" Int "," Stmt "]"

    //TODO: Find way to verify if every number in code is lesser than 256 and greater than -256 - E < 256 and E > -257
    
    // Mapping stmts
    rule <init> S:Stmt P:Pgm => P </init>
        <stmts> .List => ListItem([0, S]) </stmts>

    rule <init> S:Stmt => . </init>
        <stmts> .List => ListItem([0, S]) </stmts>

    rule <init> S:Stmt P:Pgm => P </init>
        <stmts>... ListItem([I:Int, T:Stmt]) => ListItem([I, T]) ListItem([I +Int 1, S]) </stmts>

    rule <init> S:Stmt => . </init>
        <stmts>... ListItem([I:Int, T:Stmt]) => ListItem([I, T]) ListItem([I +Int 1, S]) </stmts>
    
    // Mapping labels
    rule <state> MAPPING </state>
        <init> . </init>
        <labels> Ls:Map (. => L |-> I) </labels>
        <stmts>... ListItem([I:Int, L:Label :]) ...</stmts>
        when notBool (L in keys(Ls))

    rule <state> MAPPING => ERROR </state>// prevent duplicity of labels
        <init> . </init>
        <labels> _:Map (L:Label |-> Lm:Int) </labels>
        <stmts>... ListItem([Ln:Int, L :]) ...</stmts>
        when Lm =/=Int Ln 

    // When mapping finishes
    rule <init> . </init>
        <state> MAPPING => RUNNING </state>

    /////////// Program execution //////////////

    // Execution
    rule <state> RUNNING </state>
        <k> . => S </k>
        <pc> PC => PC +Int 1 </pc>
        <stmts>... ListItem([PC:Int, S:K]) ...</stmts>

    // Loop labels
    rule <k> _:Label : => . </k> [structural]

    // When running finishes
    rule <k> . </k> 
        <pc> PC:Int </pc>
        <stmts>... ListItem([I:Int, _]) </stmts>
        <state> RUNNING => FINISHED </state>
            when PC ==Int (I +Int 1)

    /////////// Registers content assurance //////////

    // Int from expression will be turned into MInt
    rule <registers>... _ |-> (I:Int => toByte(uvalueMInt(toByte(I)))) ...</registers>
    rule <pins>... _ |-> (I:Int => toByte(uvalueMInt(toByte(I)))) ...</pins> 

    // Get MInt from resolution expression
    rule <registers>... _ |-> (Res:MyList => miMInt(Res)) ...</registers>

    // Ensures 8-bits numbers in registers at any point in the execution
    rule <registers>... _ |-> ($mi(N:Int, I:Int) => toByte(uvalueMInt($mi(N, I)))) ...</registers>
        when I >Int 255 orBool I <Int 0

    /////////// Expression evaluation //////////

    // KResult 
    syntax KResult ::= Int

    // Arithmetic
    //rule - I:Int => the unary minus is behaving correctly as is (by k framework Int)
    rule I1:Int * I2:Int => I1 *Int I2
    rule I1:Int / I2:Int => I1 /Int I2
    rule I1:Int % I2:Int => I1 modInt I2
    rule ! I:Int => 0 when I =/=Int 0
    rule ! I:Int => 1 when I ==Int 0
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
    rule I1:Int ? I2:Int : _:Int => I2 when I1 =/=Int 0
    rule I1:Int ? _:Int : I3:Int => I3 when I1 ==Int 0

    /////// Arithmetic and logic instructions ///////////

    //ADD - add registers and place result in the first    
    rule <k> add Rd:Reg, Rr:Reg => . </k>
        <registers>... (Rr |-> RrV:MInt) (Rd |-> (RdV:MInt => addMInt(RdV, RrV)))  ...</registers>
        <rh> _ => addrh(RdV, RrV) </rh> 
        <rs> _ => addrv(RdV, RrV) xorBool addrn(RdV, RrV) </rs> // V⊕ N for signed tests  
        <rv> _ => addrv(RdV, RrV) </rv>
        <rn> _ => addrn(RdV, RrV) </rn>
        <rz> _ => zeroMInt(addMInt(RdV, RrV)) </rz>
        <rc> _ => overflowMInt(uaddMInt(RdV, RrV)) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // Add flags
    syntax Bool ::= addrv(MInt, MInt) [function]
    syntax Bool ::= addrh(MInt, MInt) [function]    
    syntax Bool ::= addrn(MInt, MInt) [function]    
    syntax Bool ::= addrvimpl(Bool, Bool, Bool) [function]
    syntax Bool ::= addrhimpl(Bool, Bool, Bool) [function]    

    // Get bools and result from MInts
    rule addrh(RdV:MInt, RrV:MInt) =>
        addrhimpl(bit(RdV, 3), bit(RrV, 3), bit(addMInt(RdV, RrV), 3)) [macro]

    // Get bools and result from MInts
    rule addrv(RdV:MInt, RrV:MInt) =>
        addrvimpl(bit(RdV, 7), bit(RrV, 7), bit(addMInt(RdV, RrV), 7)) [macro]
    
    // R7
    rule addrn(RdV:MInt, RrV:MInt) =>
        bit(addMInt(RdV, RrV), 7)

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
    rule <k> sub Rd:Reg, Rr:Reg => . </k>
        <registers>... Rd |-> (RdV:MInt => subMInt(RdV, RrV)) (Rr |-> RrV:MInt) ...</registers>
        <rh> _ => subrh(RdV, RrV) </rh> 
        <rs> _ => subrn(RdV, RrV) xorBool subrv(RdV, RrV) </rs> // N ⊕ V
        <rv> _ => subrv(RdV, RrV) </rv> 
        <rn> _ => subrn(RdV, RrV) </rn> // R7
        <rz> _ => zeroMInt(subMInt(RdV, RrV)) </rz> // if result is zero
        <rc> _ => overflowMInt(usubMInt(RdV, RrV)) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SUBI - subtract immediate
    rule <k> subi Rd:Reg, V:Int => . </k>
        <registers>... Rd |-> (RdV:MInt => subMInt(RdV, toByte(V))) ...</registers>
        <rh> _ => subrh(RdV, toByte(V)) </rh>
        <rs> _ => subrn(RdV, toByte(V)) xorBool subrv(RdV, toByte(V)) </rs> // N ⊕ V
        <rv> _ => subrv(RdV, toByte(V)) </rv>
        <rn> _ => subrn(RdV, toByte(V)) </rn> 
        <rz> _ => zeroMInt(subMInt(RdV, toByte(V))) </rz> // if result is zero
        <rc> _ => overflowMInt(usubMInt(RdV, toByte(V))) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    // Sub flags
    syntax Bool ::= subrv(MInt, MInt) [function]
    syntax Bool ::= subrh(MInt, MInt) [function]
    syntax Bool ::= subrn(MInt, MInt) [function]

    // Rd7 • Rr7 ¯ • R7 ¯ + Rd7 ¯ • Rr7 • R7
    rule subrv(RdV:MInt, RrV:MInt) => 
        addrvimpl(bit(RdV, 7), (notBool bit(RrV, 7)), bit(subMInt(RdV, RrV), 7)) [macro]
    
    // Rd3 ¯ • Rr3 + Rr3 • R3 + R3 • Rd3 ¯
    rule subrh(RdV:MInt, RrV:MInt) =>
        addrhimpl((notBool bit(RdV, 3)), bit(RrV, 3), (notBool bit(subMInt(RdV, RrV), 3))) [macro]

    // R7
    rule subrn(RdV:MInt, RrV:MInt) =>
        bit(subMInt(RdV, RrV), 7)

    //INC - increment //TODO: implement flags
    rule <k> inc Rd:Reg => . </k>
        <registers>... Rd |-> (RdV:MInt => addMInt(RdV, toByte(1))) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //DEC - decrement //TODO: implement flags
    rule <k> dec Rd:Reg => . </k>
        <registers>... Rd |-> (RdV:MInt => subMInt(RdV, toByte(1))) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLR - clear register //TODO: implement flags
    rule clr Rd:Reg => ldi Rd, 0 [structural]

    //SER - set register //TODO: implement flags
    rule ser Rd:Reg => ldi Rd, 255 [structural]
    
    /////////////// Branch Instructions /////////////

    //CP - compare
    rule <k> cp Rd:Reg, Rr:Reg => . </k>
        <registers>... (Rd |-> Rdv:MInt) (Rr |-> Rrv:MInt)  ...</registers>
        <rz> _ => true </rz> 
        <clockcycle> C:Int => C +Int 1 </clockcycle> 
        when eqMInt(Rdv, Rrv)

    rule <k> cp Rd:Reg, Rr:Reg => . </k>
        <registers>... (Rd |-> Rdv:MInt) (Rr |-> Rrv:MInt)  ...</registers>
        <rz> _ => false </rz> 
        <clockcycle> C:Int => C +Int 1 </clockcycle> 
        when neMInt(Rdv, Rrv)

    //TODO: implement for cp
        //<i> 0 </i>
        //<t> 0 </t>
        //<h> 0 </h>
        //<s> 0 </s>
        //<v> 0 </v>
        //<n> 0 </n>
        //<c> 0 </c>

    //JMP - jump to label
    rule <k> jmp La:Label => . </k>
        <pc> _ => Line </pc>
        <labels>... La |-> Line:Int ...</labels>
        <clockcycle> C:Int => C +Int 3 </clockcycle>

    //BREQ - branch if equal
    rule <k> breq La:Label => . </k>
        <pc> _ => Line </pc>
        <labels>... La |-> Line:Int ...</labels>
        <rz> true </rz>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    rule <k> breq _ => . </k>
        <rz> false </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //BRNE - branch if not equal
    rule <k> brne La:Label => .  </k>
        <pc> _ => Line </pc>
        <labels>... La |-> Line:Int ...</labels>
        <rz> false </rz>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    rule <k> brne _ => . </k>
        <rz> true </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    /////////////// Data Transfer //////////////////

    //MOV - copy register
    rule <k> mov Rd:Reg, Rr:Reg => . </k>
        <registers>... Rd |-> (_ => RrV) (Rr |-> RrV:MInt) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //LDI - load immediate
    rule <k> ldi Rd:Reg, V:Int => . </k> 
        <registers>... Rd |-> (_ => V) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
   
    //IN - read input into register
    rule <k> in Rd:Reg, Ior:IOReg => . </k>
        <pins>... (Ior |-> IorV:MInt) ...</pins> 
        <registers>... Rd |-> (_ => IorV) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
   
    //OUT - configure pins for out or in
    rule <k> out Ior:IOReg, Rr:Reg => . </k> 
        <registers>...  (Rr |-> RrV:MInt) ...</registers>
        <pins>... Ior |-> (_ => RrV) ...</pins>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
   
    ///////// Bit and Bit-test instructions /////////

    //ROR - Rotate right through carry
    rule <k> ror Rd:Reg => . </k>
        <registers>... Rd |-> (Rdv:MInt => orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1))) ...</registers>
        <rs> _ => bit(orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)), 7) xorBool bit(orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)), 7) xorBool bit(Rdv, 0) </rs> //N ⊕ V
        <rv> _ => bit(orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)), 7) xorBool bit(Rdv, 0) </rv> //N ⊕ C
        <rn> _ => bit(orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)), 7) </rn>
        <rz> _ => eqMInt((orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1))), toByte(0)) </rz>
        <rc> Cv:Bool => bit(Rdv, 0) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //ASR - Arithmetic shift right
    rule <k> asr Rd:Reg => . </k>
        <registers>... Rd |-> (Rdv:MInt => sshrMInt(Rdv,1)) ...</registers>
        <rs> _ => bit(sshrMInt(Rdv, 1), 7) xorBool (bit(sshrMInt(Rdv,1), 7) xorBool bit(Rdv, 0)) </rs>//N ⊕ V
        <rv> _ => bit(sshrMInt(Rdv, 1), 7) xorBool bit(Rdv, 0) </rv> //N ⊕ C
        <rn> _ => bit(sshrMInt(Rdv, 1), 7) </rn>
        <rz> _ => eqMInt(sshrMInt(Rdv, 1), toByte(0)) </rz>
        <rc> _ => bit(Rdv, 0) </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SWAP - Swap nibbles
    rule <k> swap Rd:Reg => . </k>
        <registers>...  Rd |-> (Rdv:MInt => orMInt(shlMInt(Rdv, 4), ashrMInt(Rdv, 4))) ...</registers>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //BSET - Set flag
    rule <k> bset S:Int => sec </k>
        when S ==Int 0 [structural]
        
    rule <k> bset S:Int => sez </k> 
        when S ==Int 1 [structural]
        
    rule <k> bset S:Int => sen </k> 
        when S ==Int 2 [structural]
        
    rule <k> bset S:Int => sev </k> 
        when S ==Int 3 [structural]
        
    rule <k> bset S:Int => ses </k> 
        when S ==Int 4 [structural]
        
    rule <k> bset S:Int => seh </k> 
        when S ==Int 5 [structural]
        
    rule <k> bset S:Int => set </k>
        when S ==Int 6 [structural]
        
    rule <k> bset S:Int => sei </k> 
        when S ==Int 7 [structural]

    //BCLR - Clear flag
    rule <k> bclr S:Int => clc </k> 
        when S ==Int 0 [structural]
        
    rule <k> bclr S:Int => clz </k> 
        when S ==Int 1 [structural]
        
    rule <k> bclr S:Int => cln </k> 
        when S ==Int 2 [structural]
        
    rule <k> bclr S:Int => clv </k> 
        when S ==Int 3 [structural]
        
    rule <k> bclr S:Int => cls </k> 
        when S ==Int 4 [structural]
        
    rule <k> bclr S:Int => clh </k> 
        when S ==Int 5 [structural]
        
    rule <k> bclr S:Int => clt </k> 
        when S ==Int 6 [structural]
        
    rule <k> bclr S:Int => cli </k> 
        when S ==Int 7 [structural]
        
    //SBI P,b - Set bit in I/O register
    rule <k> sbi Ior:LowIOReg, B:Int => . </k>
        <pins>... Ior |-> (Iorv:MInt => set(Iorv, B)) ...</pins>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    //CBI P,b - Clear bit in I/O register
    rule <k> cbi Ior:LowIOReg, B:Int => . </k>
        <pins>... Ior |-> (Iorv:MInt => clr(Iorv, B)) ...</pins>
        <clockcycle> C:Int => C +Int 2 </clockcycle>

    //BST Rr,b - Bit store from register to T
    rule <k> bst Rd:Reg, B:Int => . </k>
        <registers>... Rd |-> Rdv:MInt ...</registers>
        <rt> _ => bit(Rdv, B) </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //BLD Rd,b - Bit load from register to T
    rule <k> bld Rd:Reg, B:Int => . </k>
        <registers>... Rd |-> (Rdv:MInt => set(Rdv, B)) ...</registers>
        <rt> true </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    rule <k> bld Rd:Reg, B:Int => . </k>
        <registers>... Rd |-> (Rdv:MInt => clr(Rdv, B)) ...</registers>
        <rt> false </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEC - Set carry flag
    rule <k> sec => . </k>
        <rc> _ => true </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLC - Clear carry flag
    rule <k> clc => . </k>
        <rc> _ => false </rc>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEN - Set negative flag
    rule <k> sen => . </k>
        <rn> _ => true </rn>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLN - Clear negative flag
    rule <k> cln => . </k>
        <rn> _ => false </rn>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEZ - Set zero flag
    rule <k> sez => . </k>
        <rz> _ => true </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLZ - Clear zero flag
    rule <k> clz => . </k>
        <rz> _ => false </rz>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEI - Set interrupt flag
    rule <k> sei => . </k>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
        <ri> _ => true </ri>

    //CLI - Clear interrupt flag
    rule <k> cli => . </k>
        <ri> _ => false </ri>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SES - Set signed flag
    rule <k> ses => . </k>
        <rs> _ => true </rs>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLN - Clear signed flag
    rule <k> cls => . </k>
        <rs> _ => false </rs>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEV - Set overflow flag
    rule <k> sev => . </k>
        <rv> _ => true </rv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLV - Clear overflow flag
    rule <k> clv => . </k>
        <rv> _ => false </rv>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SET - Set T-flag
    rule <k> set => . </k>
        <rt> _ => true </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLT - Clear T-flag
    rule <k> clt => . </k>
        <rt> _ => false </rt>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //SEH - Set half carry flag
    rule <k> seh => . </k>
        <rh> _ => true </rh>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //CLH - Clear half carry flag
    rule <k> clh => . </k>
        <rh> _ => false </rh>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    /////////////////// MCU control ////////////////////

    //SLEEP - sleep
    rule <k> sleep => . </k>
        <clockcycle> C:Int => C +Int 1 </clockcycle>

    //NOP - no operation
    rule <k> nop => . </k>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
    
    //WDR - watchdog reset
    rule <k> wdr => . </k>
        <clockcycle> C:Int => C +Int 1 </clockcycle>
    
    //BREAK - for on-chip debug
    rule <k> break => . </k>

endmodule

