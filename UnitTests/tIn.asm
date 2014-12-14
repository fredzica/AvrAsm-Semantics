clr R16 ; Clear r16
ser R17 ; Set r17
out PORTB,R16 
;@vmem PORTB, 0x00
in R18,PORTB 
;@vmem R18, 0x00

out PORTB,R17 
;@vmem PORTB, 0xFF
in R19,PORTB
;@vmem R19, 0xFF
