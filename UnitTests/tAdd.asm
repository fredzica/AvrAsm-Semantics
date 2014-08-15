ldi R16, -128
ldi R17, -127
add R16, R17
;@vreg R16, 1
;@vsreg 0x19

ldi R16, 100
ldi R17, 200
add R16, R17
;@vreg R16, 44
;@vsreg 0x01

ldi R16, -100
ldi R17, 150
add R16, R17
;@vreg R16, 50 
;@vsreg 0x39

ldi R16, 0
ldi R17, 0
add R16, R17
;@vreg R16, 0
;@vsreg 0x02

ldi R16, 255
ldi R17, 1
add R16, R17
;@vreg R16, 0
;@vsreg 0x23

ldi R16, 120
ldi R17, 255
add R16, R17
;@vreg R16, 119
;@vsreg 0x21
