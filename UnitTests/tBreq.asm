begin:
    ldi R16, 0
    ldi R17, 255
    myLabel:
        inc R16
        cp R16, R17
        brne myLabel
        breq end

    myLabel2:
        jmp begin

    end:

;@vmem R16, 255
;@vclk 1023
