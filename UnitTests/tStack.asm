#include "tn2313def.inc"

ldi R16, RAMEND
out SPL, R16

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
;@vmem R17, 59
;@vstack 99

pop R17
;@vmem R17, 99
;@vstack 100

pop R17
;@vmem R17, 100

push R16

