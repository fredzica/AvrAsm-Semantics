require "bits.k"
require "unittest.k"

module AVRASM_SYNTAX
imports UNIT_TEST_SYNTAX

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
    imports AVRASM_SYNTAX
    imports BITS
    imports UNIT_TEST

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
                R0 |-> 0 R1 |-> 0 R2 |-> 0 R3 |-> 0 R4 |-> 0 R5 |-> 0 R6 |-> 0 R7 |-> 0 R8 |-> 0 R9 |-> 0 R10 |-> 0 R11 |-> 0 R12 |-> 0
                R13 |-> 0 R14 |-> 0 R15 |-> 0 R16 |-> 0 R17 |-> 0 R18 |-> 0 R19 |-> 0 R20 |-> 0 R21 |-> 0 R22 |-> 0 R23 |-> 0 R24 |-> 0 
                R25 |-> 0 R26 |-> 0 R27 |-> 0 R28 |-> 0 R29 |-> 0 R30 |-> 0 R31 |-> 0
            </registers>
            <pins>
                PORTA |-> 0 PORTB |-> 0 PORTC |-> 0 PORTD |-> 0 DDRA |-> 0 DDRB |-> 0 DDRC |-> 0 DDRD |-> 0 
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
        <stmts>... ListItem([I,T]) => ListItem([I,T]) ListItem([I +Int 1, S]) </stmts>

    rule <init> S:Stmt => . </init>
        <stmts>... ListItem([I,T]) => ListItem([I,T]) ListItem([I +Int 1, S]) </stmts>
    
    // Mapping labels
    rule <state> MAPPING </state>
        <init> . </init>
        <labels> Ls:Map (. => L |-> I) </labels>
        <stmts>... ListItem([I, L :]) ...</stmts>
        when notBool (L in keys(Ls))

    rule <state> MAPPING => ERROR </state>// prevent duplicity of labels
        <init> . </init>
        <labels> Ls:Map (L |-> Lm) </labels>
        <stmts>... ListItem([Ln, L :]) ...</stmts>
        when Lm =/=Int Ln 

    // When mapping finishes
    rule <init> . </init>
        <state> MAPPING => RUNNING </state>

    /////////// Program execution //////////////

    // Execution
    rule <state> RUNNING </state>
        <k> . => S </k>
        <pc> PC => PC +Int 1 </pc>
        <stmts>... ListItem([PC, S]) ...</stmts>

    // Loop labels
    rule <k> Label : => . </k> [structural]

    // When running finishes
    rule <k> . </k> 
        <pc> PC </pc>
        <stmts>... ListItem([I, _]) </stmts>
        <registers>... _ |-> (MI:MInt => toByte(uvalueMInt(MI)))  ...</registers>
        <state> RUNNING => FINISHED </state> when PC ==Int (I +Int 1)

    /////////// Expression evaluation //////////

    // KResult 
    syntax KResult ::= Int

    // Int from expression will be turned into MInt
    rule <registers>... _ |-> (I:Int => toByte(uvalueMInt(toByte(I)))) ...</registers>
    rule <pins>... _ |-> (I:Int => toByte(uvalueMInt(toByte(I)))) ...</pins> 

    // Get MInt from resolution expression
    rule <registers>... _ |-> (Res:MyList => miMInt(Res)) ...</registers>

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
    rule I1:Int ? I2:Int : I3:Int => I2 when I1 =/=Int 0
    rule I1:Int ? I2:Int : I3:Int => I3 when I1 ==Int 0

    /////// Arithmetic and logic instructions ///////////

    //ADD - add registers and place result in the first    
    rule <k> add Rd, Rr => . </k>
        <registers>... (Rr |-> RrV) (Rd |-> (RdV => addMInt(RdV, RrV)))  ...</registers>
        <rh> _ => addrh(bit(RdV, 3), bit(RrV, 3), bit(addMInt(RdV, RrV), 3)) </rh> 
        <rs> _ => addrv(bit(RdV, 7), bit(RrV, 7), bit(addMInt(RdV, RrV), 7)) xorBool bit(addMInt(RdV, RrV), 7) </rs> // V⊕ N for signed tests  
        <rv> _ => addrv(bit(RdV, 7), bit(RrV, 7), bit(addMInt(RdV, RrV), 7)) </rv>
        <rn> _ => bit(addMInt(RdV, RrV), 7) </rn>
        <rz> _ => eqMInt(addMInt(RdV, RrV), toByte(0)) </rz>
        <rc> _ => overflowMInt(uaddMInt(RdV, RrV)) </rc>
        <clockcycle> C => C +Int 1 </clockcycle>

    // Add flags
    syntax Bool ::= addrv(Bool, Bool, Bool) [function]
    syntax Bool ::= addrh(Bool, Bool, Bool) [function]    

    // Rd7 • Rr7 • R7 ¯ + Rd7 ¯ • Rr7 ¯ • R7 - What is the meaning of this???
    rule addrv(Rd7b, Rr7b, R7b) => 
        Rd7b andBool 
        Rr7b andBool
        (notBool R7b) orBool
        (notBool Rd7b) andBool
        (notBool Rr7b) andBool
        R7b [macro]

    // Rd3 • Rr3 + Rr3 • R3 ¯ + R3 ¯ • Rd3
    rule addrh(Rd3b, Rr3b, R3b) => 
        Rd3b andBool
        Rr3b orBool
        Rr3b andBool
        (notBool R3b) orBool
        (notBool R3b) andBool
        Rd3b [macro]

    //SUB - subtract registers and place result in the first    
    rule <k> sub Rd, Rr => . </k>
        <registers>... Rd |-> (RdV => subMInt(RdV, RrV)) (Rr |-> RrV) ...</registers>
        <clockcycle> C => C +Int 1 </clockcycle>

    //SUBI - subtract immediate
    rule <k> subi Rd, K => . </k>
        <registers>... Rd |-> (RdV => subMInt(RdV, toByte(K))) ...</registers>
        <clockcycle> C => C +Int 1 </clockcycle>

    //INC - increment
    rule <k> inc Rd => . </k>
        <registers>... Rd |-> (RdV => addMInt(RdV, toByte(1))) ...</registers>
        <clockcycle> C => C +Int 1 </clockcycle>

    //DEC - decrement
    rule <k> dec Rd => . </k>
        <registers>... Rd |-> (RdV => subMInt(RdV, toByte(1))) ...</registers>
        <clockcycle> C => C +Int 1 </clockcycle>

    //CLR - clear register
    rule clr Rd => ldi Rd, 0 [structural]

    //SER - set register
    rule ser Rd => ldi Rd, 255 [structural]
    
    /////////////// Branch Instructions /////////////

    //CP - compare
    rule <k> cp Rd, Rr => . </k>
        <registers>... (Rd |-> Rdv) (Rr |-> Rrv)  ...</registers>
        <rz> Z => true </rz> 
        <clockcycle> C => C +Int 1 </clockcycle> 
        when eqMInt(Rdv, Rrv)

    rule <k> cp Rd, Rr => . </k>
        <registers>... (Rd |-> Rdv) (Rr |-> Rrv)  ...</registers>
        <rz> Z => false </rz> 
        <clockcycle> C => C +Int 1 </clockcycle> 
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
    rule <k> jmp La => . </k>
        <pc> _ => Line </pc>
        <clockcycle> C => C +Int 3 </clockcycle>
        <labels>... La |-> Line ...</labels>

    //BREQ - branch if equal
    rule <k> breq La => . </k>
        <pc> _ => Line </pc>
        <clockcycle> C => C +Int 2 </clockcycle>
        <labels>... La |-> Line ...</labels>
        <rz> true </rz>

    rule <k> breq La => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rz> false </rz>

    //BRNE - branch if not equal
    rule <k> brne La => .  </k>
        <pc> _ => Line </pc>
        <clockcycle> C => C +Int 2 </clockcycle>
        <labels>... La |-> Line ...</labels>
        <rz> false </rz>

    rule <k> brne La => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rz> true </rz>

    /////////////// Data Transfer //////////////////

    //MOV - copy register
    rule <k> mov Rd, Rr => . </k>
        <registers>... Rd |-> (_ => RrV) (Rr |-> RrV) ...</registers>
        <clockcycle> C => C +Int 1 </clockcycle>

    //LDI - load immediate
    rule <k> ldi Rd, K => . </k> 
        <registers>... Rd |-> (_ => K) ...</registers>
        <clockcycle> C => C +Int 1 </clockcycle>
   
    //IN - read input into register
    rule <k> in Rd, Ior => . </k>
        <pins>... (Ior |-> IorV) ...</pins> 
        <registers>... Rd |-> (_ => IorV) ...</registers>
        <clockcycle> C => C +Int 1 </clockcycle>
   
    //OUT - configure pins for out or in
    rule <k> out Ior, Rr => . </k> 
        <registers>...  (Rr |-> RrV) ...</registers>
        <pins>... Ior |-> (_ => RrV) ...</pins>
        <clockcycle> C => C +Int 1 </clockcycle>
   
    ///////// Bit and Bit-test instructions /////////

    //ROR - Rotate right through carry
    rule <k> ror Rd => . </k>
        <registers>... Rd |-> (Rdv => orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1))) ...</registers>
        <rs> _ => bit(orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)), 7) xorBool bit(orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)), 7) xorBool bit(Rdv, 0) </rs> //N ⊕ V
        <rv> _ => bit(orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)), 7) xorBool bit(Rdv, 0) </rv> //N ⊕ C
        <rn> _ => bit(orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1)), 7) </rn>
        <rz> _ => eqMInt((orMInt(shlMInt(BooltoMInt(Cv), 7), ashrMInt(Rdv, 1))), toByte(0)) </rz>
        <rc> Cv => bit(Rdv, 0) </rc>
        <clockcycle> C => C +Int 1 </clockcycle>

    //ASR - Arithmetic shift right
    rule <k> asr Rd => . </k>
        <registers>... Rd |-> (Rdv => sshrMInt(Rdv,1)) ...</registers>
        <rs> _ => bit(sshrMInt(Rdv, 1), 7) xorBool (bit(sshrMInt(Rdv,1), 7) xorBool bit(Rdv, 0)) </rs>//N ⊕ V
        <rv> _ => bit(sshrMInt(Rdv, 1), 7) xorBool bit(Rdv, 0) </rv> //N ⊕ C
        <rn> _ => bit(sshrMInt(Rdv, 1), 7) </rn>
        <rz> _ => eqMInt(sshrMInt(Rdv, 1), toByte(0)) </rz>
        <rc> _ => bit(Rdv, 0) </rc>
        <clockcycle> C => C +Int 1 </clockcycle>

    //SWAP - Swap nibbles
    rule <k> swap Rd => . </k>
        <registers>...  Rd |-> (Rdv => orMInt(shlMInt(Rdv, 4), ashrMInt(Rdv, 4))) ...</registers>
        <clockcycle> C => C +Int 1 </clockcycle>

    //BSET - Set flag
    rule <k> bset S => sec </k>
        when S ==Int 0 [structural]
        
    rule <k> bset S => sez </k> 
        when S ==Int 1 [structural]
        
    rule <k> bset S => sen </k> 
        when S ==Int 2 [structural]
        
    rule <k> bset S => sev </k> 
        when S ==Int 3 [structural]
        
    rule <k> bset S => ses </k> 
        when S ==Int 4 [structural]
        
    rule <k> bset S => seh </k> 
        when S ==Int 5 [structural]
        
    rule <k> bset S => set </k>
        when S ==Int 6 [structural]
        
    rule <k> bset S => sei </k> 
        when S ==Int 7 [structural]

    //BCLR - Clear flag
    rule <k> bclr S => clc </k> 
        when S ==Int 0 [structural]
        
    rule <k> bclr S => clz </k> 
        when S ==Int 1 [structural]
        
    rule <k> bclr S => cln </k> 
        when S ==Int 2 [structural]
        
    rule <k> bclr S => clv </k> 
        when S ==Int 3 [structural]
        
    rule <k> bclr S => cls </k> 
        when S ==Int 4 [structural]
        
    rule <k> bclr S => clh </k> 
        when S ==Int 5 [structural]
        
    rule <k> bclr S => clt </k> 
        when S ==Int 6 [structural]
        
    rule <k> bclr S => cli </k> 
        when S ==Int 7 [structural]
        
    //SBI P,b - Set bit in I/O register
    rule <k> sbi Ior, B => . </k>
        <pins>... Ior |-> (Iorv => set(Iorv, B)) ...</pins>
        <clockcycle> C => C +Int 2 </clockcycle>

    //CBI P,b - Clear bit in I/O register
    rule <k> cbi Ior, B => . </k>
        <pins>... Ior |-> (Iorv => clr(Iorv, B)) ...</pins>
        <clockcycle> C => C +Int 2 </clockcycle>

    //BST Rr,b - Bit store from register to T
    rule <k> bst Rd, B => . </k>
        <registers>... Rd |-> Rdv ...</registers>
        <rt> _ => bit(Rdv, B) </rt>
        <clockcycle> C => C +Int 1 </clockcycle>

    //BLD Rd,b - Bit load from register to T
    rule <k> bld Rd, B => . </k>
        <registers>... Rd |-> (Rdv => set(Rdv, B)) ...</registers>
        <rt> true </rt>
        <clockcycle> C => C +Int 1 </clockcycle>

    rule <k> bld Rd, B => . </k>
        <registers>... Rd |-> (Rdv => clr(Rdv, B)) ...</registers>
        <rt> false </rt>
        <clockcycle> C => C +Int 1 </clockcycle>

    //SEC - Set carry flag
    rule <k> sec => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rc> _ => true </rc>

    //CLC - Clear carry flag
    rule <k> clc => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rc> _ => false </rc>

    //SEN - Set negative flag
    rule <k> sen => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rn> _ => true </rn>

    //CLN - Clear negative flag
    rule <k> cln => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rn> _ => false </rn>

    //SEZ - Set zero flag
    rule <k> sez => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rz> _ => true </rz>

    //CLZ - Clear zero flag
    rule <k> clz => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rz> _ => false </rz>

    //SEI - Set interrupt flag
    rule <k> sei => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <ri> _ => true </ri>

    //CLI - Clear interrupt flag
    rule <k> cli => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <ri> _ => false </ri>

    //SES - Set signed flag
    rule <k> ses => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rs> _ => true </rs>

    //CLN - Clear signed flag
    rule <k> cls => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rs> _ => false </rs>

    //SEV - Set overflow flag
    rule <k> sev => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rv> _ => true </rv>

    //CLV - Clear overflow flag
    rule <k> clv => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rv> _ => false </rv>

    //SET - Set T-flag
    rule <k> set => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rt> _ => true </rt>

    //CLT - Clear T-flag
    rule <k> clt => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rt> _ => false </rt>

    //SEH - Set half carry flag
    rule <k> seh => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rh> _ => true </rh>

    //CLH - Clear half carry flag
    rule <k> clh => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
        <rh> _ => false </rh>

    /////////////////// MCU control ////////////////////

    //SLEEP - sleep
    rule <k> sleep => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>

    //NOP - no operation
    rule <k> nop => . </k>
        <clockcycle> C => C +Int 1 </clockcycle>
    
    //BREAK - for on-chip debug
    rule <k> break => . </k>

endmodule

