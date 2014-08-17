clr R16 ; Clear r16
ser R17 ; Set r17
out PORTB,R16 
;@vpin PORTB, 0x00
in R18,PORTB 
;@vreg R18, 0x00

out PORTB,R17 
;@vpin PORTB, 0xFF
in R19,PORTB
;@vreg R19, 0xFF
