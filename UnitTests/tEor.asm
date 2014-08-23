eor R16, R17

ldi R16, 50
ldi R17, 255
eor R16, R17
;@vreg R16, 205
;@vsreg 20

eor R16, R16
;@vreg R16, 0
;@vsreg 2

ldi R16, 75
ldi R17, 123
eor R16, R17
;@vreg R16, 48
;@vsreg 0

ldi R16, 0b10000000
ldi R17, 0b01111111
eor R16, R17
;@vreg R16, 0xFF
;@vsreg 20

