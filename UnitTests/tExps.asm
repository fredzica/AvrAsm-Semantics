ldi R1, 6/3 + 12/5
;@vmem R1, 4

ldi R2, 3*6
;@vmem R2, 18

ldi R3, (2-1)+1
;@vmem R3, 2

ldi R4, !19 + !0 + !0
;@vmem R4, 2

ldi R5, 513
;@vmem R5, 1

ldi R6, -1
;@vmem R6, 255

ldi R7, 0b11111111
;@vmem R7, 255

ldi R8, $ff
;@vmem R8, 255

ldi R9, 0xaf
;@vmem R9, 175

ldi R10, 010
;@vmem R10, 8

ldi R11, 12 % 5
;@vmem R11, 2

ldi R12, 1 << 7
;@vmem R12, 128

ldi R13, 5 >> 1
;@vmem R13, 2

ldi R14, 5 > 1
;@vmem R14, 1

ldi R14, -10 < 1
;@vmem R14, 1

ldi R14, 10 >= 100
;@vmem R14, 0

ldi R14, 10 <= 10
;@vmem R14, 1

ldi R14, 50 <= 100
;@vmem R14, 1

ldi R15, 500 == 500
;@vmem R15, 1

ldi R15, 500 != 10
;@vmem R15, 1

ldi R15, 10 != 10
;@vmem R15, 0

ldi R15, 100 == 23
;@vmem R15, 0

ldi R16, ~128
;@vmem R16, 127

ldi R17, 255 & 12
;@vmem R17, 12

ldi R18, 0b10001000 ^ 0b01110111
;@vmem R18, 0xff

ldi R19, 0b00010000 | 0b01000000
;@vmem R19, 0b01010000

ldi R20, 10213 && 20
;@vmem R20, 1

ldi R20, 10 && 0
;@vmem R20, 0

ldi R20, 0 && 0
;@vmem R20, 0

ldi R21, 10 || 0
;@vmem R21, 1

ldi R21, 0 || 0
;@vmem R21, 0

ldi R21, 32 || 23
;@vmem R21, 1 

ldi R22, 100 ? 1 : 0
;@vmem R22, 1

ldi R22, 1>=0 ? 2 : 0
;@vmem R22, 2

ldi R22, 0 ? 10 : 20
;@vmem R22, 20

ldi R22, 10 >= 100? 100 : 50
;@vmem R22, 50

ldi R23, -130
;@vmem R23, 126
