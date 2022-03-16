EXTRN output_X: near ; метка для ближнего перехода (адрес занимает 2 байта, так как ближний переход совершается в пределах того же сегмента, поэтому нужно передать только смещение)

STK SEGMENT PARA STACK 'STACK'
	db 100 dup(0)
STK ENDS

DSEG SEGMENT PARA PUBLIC 'DATA'
	X db 'R'
DSEG ENDS

CSEG SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG, DS:DSEG, SS:STK
main:
	mov ax, DSEG
	mov ds, ax    ; записываем в регистр DS адрес начала сегмента DSEG

	call output_X

	mov ax, 4c00h ; завершение программы
	int 21h
CSEG ENDS

PUBLIC X

END main