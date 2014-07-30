ldi R0 123
ldi R1 2
ldi R3 12

add R0 R1
add R2 R3

mov R31 R0

sub R31 R1

subi R31 10

dec R31
inc R1

clr R31
ser R1
inc R31

sleep
nop

teste:
    in R1 PORTA
    out DDRC R31
beste:
    add R0 R1
ceste:
    add R1 R2
