PUBLIC input_matrix
PUBLIC replace_elems
PUBLIC output_matrix

DSEG SEGMENT PARA PUBLIC 'DATA'
    InputRowsCntMSG     db "Enter the the number of matrix rows (1 - 9): ", '$'
    InputColsCntMSG     db "Enter the the number of matrix columns (1 - 9): ", '$'
	InputMatrElemsMSG   db "Enter the matrix elems: ", '$'
    MatrixRowsCnt       db 0
    MatrixColsCnt       db 0
	MatrixElems         db 9 * 9 dup(0)
	OutputMSG           db "The first 9 English letters have been replaced by their numbers: ", '$'
	Endline             db 13, 10, '$'
DSEG ENDS

CSEG2 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG2, DS:DSEG

input_rows_cnt proc near
    mov dx, OFFSET InputRowsCntMSG
	mov ah, 09h
	int 21h                             ; выводим приглашение к вводу количества строк матрицы

    mov ah, 01h
    int 21h
    sub al, '0'
    mov MatrixRowsCnt, al               ; вводим количество строк матрицы

    mov dx, OFFSET Endline
	mov ah, 09h
	int 21h                             ; переходим на новую строку

    ret
input_rows_cnt endp

input_columns_cnt proc near
    mov dx, OFFSET InputColsCntMSG
	mov ah, 09h
	int 21h                             ; выводим приглашение к вводу количества столбцов матрицы

    mov ah, 01h
    int 21h
    sub al, '0'
    mov MatrixColsCnt, al               ; вводим количество столбцов матрицы

    mov dx, OFFSET Endline
	mov ah, 09h
	int 21h                             ; переходим на новую строку

    ret
input_columns_cnt endp

input_matrix_elems proc near
    mov dx, OFFSET InputMatrElemsMSG
	mov ah, 09h
	int 21h                             ; выводим приглашение к вводу элементов матрицы

    mov dx, OFFSET Endline
	mov ah, 09h
	int 21h                             ; переходим на новую строку

    xor si, si                          ; индекс элемента матрицы
    xor cx, cx
    mov cl, MatrixRowsCnt               ; в качестве счётчика используем cl, а не cx, так как MatrixRowsCnt занимает 1 байт, а не 2

    input_rows:
        mov bx, cx                      ; сохраняем значение cx
        mov cl, MatrixColsCnt

        input_columns:
            mov ah, 01h                 ; вводим символ
            int 21h

            mov MatrixElems[si], al     ; помещаем символ в матрицу
            inc si                      ; увеличиваем индекс текущего элемента массива
            
            mov dx, ' '
            mov ah, 02h
            int 21h                     ; ставим пробел

            loop input_columns
        
        mov dx, OFFSET Endline
        mov ah, 09h
        int 21h                         ; переходим на новую строку
        
        mov cx, bx                      ; восстанавливаем значение cx
        
        mov al, 9
        sub al, MatrixColsCnt
        xor ah, ah
        add si, ax                      ; смещаем si на следующую строку матрицы

        loop input_rows

    ret
input_matrix_elems endp

input_matrix proc far
    mov ax, DSEG
    mov ds, ax                          ; записываем в регистр DS адрес начала сегмента DSEG

    call input_rows_cnt
    call input_columns_cnt
    call input_matrix_elems

    ret
input_matrix endp

replace_elems proc far
    mov dx, OFFSET Endline
	mov ah, 09h
	int 21h                             ; переходим на новую строку
    
    xor si, si                          ; индекс элемента матрицы
    xor cx, cx
    mov cl, MatrixRowsCnt               ; в качестве счётчика используем cl, а не cx, так как MatrixRowsCnt занимает 1 байт, а не 2

    rows_processing:
        mov bx, cx                      ; сохраняем значение cx
        mov cl, MatrixColsCnt

        columns_processing:
            cmp MatrixElems[si], 'a'
            jb skip_elem                ; если символ идёт до 'a', то пропускаем его
            cmp MatrixElems[si], 'i'
            ja skip_elem                ; если символ идёт после 'i', то пропускаем его
            
            sub MatrixElems[si], 'a'
            add MatrixElems[si], '1'    ; меняем символ на его номер в алфавите

            skip_elem:

            inc si                      ; увеличиваем индекс текущего элемента массива
            loop columns_processing
        
        mov cx, bx                      ; восстанавливаем значение cx

        mov al, 9
        sub al, MatrixColsCnt
        xor ah, ah
        add si, ax                      ; смещаем si на следующую строку матрицы

        loop rows_processing

    ret
replace_elems endp

output_matrix proc far
    mov dx, OFFSET OutputMSG
	mov ah, 09h
	int 21h                             ; выводим подсказку к выводу матрицы

    mov dx, OFFSET Endline
	mov ah, 09h
	int 21h                             ; переходим на новую строку
    
    xor si, si                          ; индекс элемента матрицы
    xor cx, cx
    mov cl, MatrixRowsCnt               ; в качестве счётчика используем cl, а не cx, так как MatrixRowsCnt занимает 1 байт, а не 2

    output_rows:
        mov bx, cx                      ; сохраняем значение cx
        mov cl, MatrixColsCnt

        output_columns:
            mov dl, MatrixElems[si]
            mov ah, 02h
	        int 21h                     ; выводим символ матрицы

            inc si                      ; увеличиваем индекс текущего элемента массива
            
            mov dx, ' '
            mov ah, 02h
            int 21h                     ; ставим пробел

            loop output_columns
        
        mov dx, OFFSET Endline
        mov ah, 09h
        int 21h                         ; переходим на новую строку

        mov cx, bx                      ; восстанавливаем значение cx

        mov al, 9
        sub al, MatrixColsCnt
        xor ah, ah
        add si, ax                      ; смещаем si на следующую строку матрицы
        
        loop output_rows

    ret
output_matrix endp
	
CSEG2 ENDS
END
