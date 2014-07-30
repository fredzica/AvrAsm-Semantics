clr R0
ser R2

ldi R3 255
clr R4

init:
    clr R0
loop:
    inc R0
    cp R0 R2
    brne loop

loop2:
    cp R4 R3
    breq end

loop3:
    cp R4 R3
    inc R4
    brne init
    ldi R31 100

end:
