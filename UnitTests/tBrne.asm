ldi R16, 1
ldi R17, 0
myLabel:
    inc R16
    cp R16, R17
    brne myLabel

;@vreg R16, 0
;@vclk 1021
