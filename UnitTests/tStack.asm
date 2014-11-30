ldi R16, 100
push R16
;@vstack 100

ldi R16, 99
push R16
;@vstack 99

ldi R31, 59
push R31
;@vstack 59


pop R17
;@vreg R17, 59
;@vstack 99

pop R17
;@vreg R17, 99
;@vstack 100

pop R17
;@vreg R17, 100

pop R16
;@vreg R16, 0

push R16

