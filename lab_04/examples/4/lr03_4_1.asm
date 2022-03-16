PUBLIC X
EXTRN exit: far ; метка для дальнего перехода (адрес занимает 4 байта, так как дальний переход совершается в другой сегмент, поэтому нужно передать и сегментную чать адреса, и смещение)

SSTK SEGMENT para STACK 'STACK'
	db 100 dup(0)
SSTK ENDS

SD1 SEGMENT para public 'DATA'
	X db 'X'
SD1 ENDS

SC1 SEGMENT para public 'CODE'
	assume CS:SC1, DS:SD1
main:	
	jmp exit
SC1 ENDS
END main