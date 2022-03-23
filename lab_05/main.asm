; Замечание: декомпозиция на низком уровне - плохо!
EXTRN input_matrix:  far
EXTRN replace_elems: far
EXTRN output_matrix: far

SSEG SEGMENT PARA STACK 'STACK'
	db 512 dup(0)
SSEG ENDS

CSEG1 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG1, SS:SSEG
main:
	call input_matrix
    call replace_elems
    call output_matrix

	mov ax, 4c00h 			 		; завершение программы
	int 21h
	
CSEG1 ENDS
END main
