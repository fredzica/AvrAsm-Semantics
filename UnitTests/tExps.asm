ldi R1, 6/3 + 12/5
vreg R1, 4

ldi R2, 3*6
vreg R2, 18

ldi R3, (2-1)+1
vreg R3, 2

ldi R4, !19 + !0 + !0
vreg R4, 2

ldi R5, 513
vreg R5, 1

ldi R6, -1
vreg R6, 255

ldi R7, 0b11111111
vreg R7, 255

ldi R8, $ff
vreg R8, 255

ldi R9, 0xaf
vreg R9, 175

ldi R10, 010
vreg R10, 8

ldi R11, 12 % 5
vreg R11, 2

ldi R12, 1 << 7
vreg R12, 128

ldi R13, 5 >> 1
vreg R13, 2

ldi R14, 5 > 1
vreg R14, 1

ldi R14, -10 < 1
vreg R14, 1

ldi R14, 10 >= 100
vreg R14, 0

ldi R14, 10 <= 10
vreg R14, 1

ldi R14, 50 <= 100
vreg R14, 1

ldi R15, 500 == 500
vreg R15, 1

ldi R15, 500 != 10
vreg R15, 1

ldi R15, 10 != 10
vreg R15, 0

ldi R15, 100 == 23
vreg R15, 0

ldi R16, ~128
vreg R16, 127

ldi R17, 255 & 12
vreg R17, 12

ldi R18, 0b10001000 ^ 0b01110111
vreg R18, 0xff

ldi R19, 0b00010000 | 0b01000000
vreg R19, 0b01010000

ldi R20, 10213 && 20
vreg R20, 1

ldi R20, 10 && 0
vreg R20, 0

ldi R20, 0 && 0
vreg R20, 0

ldi R21, 10 || 0
vreg R21, 1

ldi R21, 0 || 0
vreg R21, 0

ldi R21, 32 || 23
vreg R21, 1 

ldi R22, 100 ? 1 : 0
vreg R22, 1

ldi R22, 1>=0 ? 2 : 0
vreg R22, 2

ldi R22, 0 ? 10 : 20
vreg R22, 20

ldi R22, 10 >= 100? 100 : 50
vreg R22, 50
