clr R16 ; Clear r16
ser R17 ; Set r17
out PORTB,R16 ; Write zeros to Port B
;@vpin PORTB, 0x00
out PORTB,R17 ; Write ones to Port B
;@vpin PORTB, 0xFF
