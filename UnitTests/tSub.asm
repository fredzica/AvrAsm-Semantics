ldi R16, 1
ldi R17, 1
sub R16, R17
;@vreg R16, 0x00
;@vsreg 0x02

ldi R16, 1
ldi R17, 2
sub R16, R17
;@vreg R16, 0xFF
;@vsreg 0x35

ldi R16, 1
ldi R17, -2
sub R16, R17
;@vreg R16, 0x03
;@vsreg 0x21

ldi R16, 150
ldi R17, 156
sub R16, R17
;@vreg R16, 0xFA
;@vsreg 0x35

ldi R16, 255
ldi R17, 123
sub R16, R17
;@vreg R16, 0x84
;@vsreg 0x14

ldi R16, 23
ldi R17, 252
sub R16, R17
;@vreg R16, 0x1B
;@vsreg 0x21

ldi R16, 124
ldi R17, -12
sub R16, R17
;@vreg R16, 0x88
;@vsreg 0x0D
