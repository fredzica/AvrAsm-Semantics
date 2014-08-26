clr R16
ser R17
ldi R18, 1
loop:
    add R16, R18
    cp R16, R17
    brne loop
  loop2 :
	nop

;@vreg R16, 0xFF
;@vreg R17, 0xFF
;@vreg R18, 0x01
;@vsreg 0x02 
;@vclk 1023 

   
