; НАПОМИНАНИЕ: МАКСИМАЛЬНЫЙ РАЗМЕР СЕГМЕНТА - 64 Килобайта
SD1 SEGMENT para public 'DATA' ; объявляем 3 сегмента размером 65534 байта (64 Килобайта - 2 байта)
	S1 db 'Y'
	db 65535 - 2 dup (0)
SD1 ENDS

SD2 SEGMENT para public 'DATA'
	S2 db 'E'
	db 65535 - 2 dup (0)
SD2 ENDS

SD3 SEGMENT para public 'DATA'
	S3 db 'S'
	db 65535 - 2 dup (0)
SD3 ENDS

CSEG SEGMENT para public 'CODE'
	assume CS:CSEG;, DS:SD1 ; связываем сегмент SD1 с регистром DS
output:           ; функция вывода символ, который лежит в dl (с переводом строки)
	mov ah, 2
	int 21h
	mov dl, 13    ; код символа "\r" (возврат каретки)
	int 21h
	mov dl, 10    ; код символа "\n" (переход на новую строку)
	int 21h
	ret
main:
	mov ax, SD1
	mov ds, ax    ; записываем в регистр DS адрес начала сегмента SD1
	mov dl, DS:S1 ; пишем явно сегментную часть адреса переменной, потому что assume я закомментировал
	call output
;assume DS:SD2     ; связываем сегмент SD2 с регистром DS
	mov ax, SD2
	mov ds, ax    ; записываем в регистр DS адрес начала сегмента SD2
	mov dl, DS:S2 ; пишем явно сегментную часть адреса переменной, потому что assume я закомментировал
	call output
;assume DS:SD3     ; связываем сегмент SD3 с регистром DS
	mov ax, SD3
	mov ds, ax    ; записываем в регистр DS адрес начала сегмента SD3
	mov dl, DS:S3 ; пишем явно сегментную часть адреса переменной, потому что assume я закомментировал
	call output
	
	mov ax, 4c00h ; завершение программы
	int 21h       ; (если не завершить явно, программа процессор продолжит выполнять команды, которые лежат дальше, т.е. мусор из оперативной памяти)
CSEG ENDS
END main