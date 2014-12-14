ldi R0, 128
bst R0, 7
;@vt true
bld R0, 0
;@vmem R0, 0b10000001
bld R0, 2
;@vmem R0, 0b10000101
bst R0, 1
;@vt false
bld R0, 7
;@vmem R0, 0b00000101
