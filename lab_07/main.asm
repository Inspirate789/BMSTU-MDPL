; "Частота автоповтора" - это та частота, с которой клавиша посылает свой код, когда  она постоянно держится нажатой.
; Следовательно, эффект программы можно увидеть, удердивая одну кнопку длительное время. В консоли будут появляться символы, 
; причём частота их появления на экране с каждой секундой будет увеличиваться.
; важно, что этот эффект будет проявляться во всей системе (в моём случае это эмулятор DOS), потому что мы устанавливаем скорость автоповтора
; на всей клавиатуре, которая используется и в других программах...

; Идея программы: "переопределить" (перехватить) прерывание таймера следующим образом: отрегулировать согласно заданию скорость автоповтора ввода, а затем вызвать исходный обработчик прерывания таймера, чтобы он сделал свои дела...

.model tiny                                                 ; Пишем такую модель памяти, чтобы создавался простейший исполняемый файл формата .COM, и все наши дальнейшие действия были корректны (да-да, я не смог сделать это для формата .exe)

CSEG SEGMENT                                                ; нет смысла добавлять описание, ведь в исполняемом файле будет только один сегмент
    assume CS:CSEG
    org 100h                                                ; делаем отступ для заголовка .COM-файла
main:
    jmp init

    handler_addr    dd 0                                    ; адрес обработчика прерываний, который мы будем перезаписывать
    is_init         db 1                                    ; признак того, установили ли мы резидента
    cur_speed       db 1Fh                                  ; задаём начальную скорость автоповтора ввода (самую минимальную - 2 симв./сек.)
    cur_time        db 0                                    ; время в секундах

inc_input_speed proc near                                   ; если бы объявили far, то при записи нужно было бы помещать адрес процедуры не в DX, а в DS:DX (вроде как, хотя какой far, у нас же тут один сегмент...)
    push ax                                                 ; сохраняем значения регистров, которые могут поменяться в процессе выполнения процедуры
    push cx
    push dx
    pushf						    ; это можно было не делать, так как в конце старого обработчика прерывания, который я вызываю в конце процедуры с помощью JMP (а не CALL) восстанавливается то  состояние регистра флагов, которое было перед вызовом прерывания (моей процедуры)

    mov ah, 02h                                             ; АН = 02h — чтение времени из RTC. Возвращает время в упакованном BCD-формате: час (в регистре СН), минуту (CL), секунду (DH) и признак коррекции летнего/зимнего времени (DL = 1 — коррекция используется, DL = 0 — нет). Признаком успешной операции является флаг CF=0.
    int 1Ah                                                 ; 1Ah - прерывание BIOS для работы с таймером

    cmp dh, cur_time
    je skip_speed_change                                    ; если время (значение количества секунд в таймере компьютера) не изменилось, то ничего не делаем

    mov cur_time, dh                                        ; если время увеличилось, то заносим его в переменную и изменяем скорость автоповтора ввода
    dec cur_speed                                           ; с уменьшением cur_speed увеличивается скорость автоповтора ввода

    cmp cur_speed, 1Fh                                      ; эта конструкция закольцовывет cur_speed в диапазоне 00h-1Fh, т.е. меняется только скорость автоповтора (в пределах 2-30 симв./сек.), а пауза перед началом автоповтора остаётся минимальной (250 мс)
    jbe set_speed
    
    mov cur_speed, 1Fh

set_speed:
    mov al, 0F3h                                            ; команда F3h отвечает за параметры режима автоповтора нажатой клавиши ; '0' в начале числа можно и не писать, но тогда MASM будет воспринимать это как метку, потому что она начинается с буквы
    out 60h, al                                             ; порт 60h предназначен для работы с клавиатурой и обычно принимает пары байтов последовательно: первый - код команды, второй - данные

    mov al, cur_speed
    out 60h, al                                             ; устанавливаем скорость автоповтора ввода

skip_speed_change:
    popf                                                    ; восстанавливаем значения регистров
    pop dx
    pop cx
    pop ax
    jmp dword ptr cs:handler_addr                           ; вызываем старый обработчик прерывния таймера
inc_input_speed endp

init:
    mov ax, 351Ch
    int 21h                                                 ; AH = 35h, AL = 1Ch - получаем адрес обработчика прерывания таймера (1Ch) в ES:BX (в ES - сегментная часть адреса, в BX - смещение)

    cmp es:is_init, 1                                       ; почему работает только обращение через es?! (Ни cs, ни ds не отрабатывают корректно) + мы только что записали в es адрес обработчика прерывания, испортив этот регистр...
    je exit                                                 ; если программа запускается не в первый раз, т.е. если адрес обработчика уже перезаписан, то выходим

    mov word ptr handler_addr, bx                           ; сохраняем адрес обработчика прерываний по частям в одну переменную
    mov word ptr handler_addr[2], es                        ; конструкция 'word ptr' нам нужна для того, чтобы обратиться по адресу (handler_addr + 2) как к ДВУХБАЙТОВОЙ сущности, в то время как переменная сама по себе весит 4 байта

    mov ax, 251Ch
    mov dx, offset inc_input_speed
    int 21h                                                 ; AH = 25h, AL = 1Ch - заменяем вектор 1Ch в таблице векторов прерываний на свой (адрес берётся из DX или DS:DX в зависимости от расстояния до процедуры: near или far)

    mov dx, offset init_msg
    mov ah, 09h
    int 21h                                                 ; выводим сообщение об установлении резидента с новым обработчиком прерывания таймера

    mov dx, offset init
    int 27h                                                 ; завершаем программу резидентной ; всё, начиная с адреса метки init, будет освобождено из памяти

exit:
    mov dx, offset exit_msg                                 ; выводим сообщение о восстановлении прежнего обработчика прерывания таймера
    mov ah, 09h
    int 21h

    ; для установки характеристик режима автоповтора в порт 60h необходимо записать код команды 0F3h, затем байт, определяющий характеристики режима
    mov al, 0F3h                                            ; команда F3h отвечает за параметры режима автоповтора нажатой клавиши ; '0' в начале числа можно и не писать, но тогда MASM будет воспринимать это как метку, потому что она начинается с буквы
    out 60h, al                                             ; порт 60h предназначен для работы с клавиатурой и обычно принимает пары байтов последовательно: первый - код команды, второй - данные

    mov al, 0
    out 60h, al                                             ; устанавливаем период автоповтора 30.0, задержку включения режима автоповтора 250 мс (восстанавливаем дефолтные значения)
    
    mov dx, word ptr es:handler_addr                       
    mov ds, word ptr es:handler_addr[2]
    mov ax, 251ch
    int 21h                                                 ; восстанавливаем старый обработчик прерывания таймера в таблице векторов прерываний

    mov ah, 49h                                             ; Надо ли вычищать память из-под резидента? И работает ли это корректно?
    int 21h

    mov ax, 4c00h
    int 21h                                                 ; классическое завершение программы
	
    init_msg db 'New interrupt handler installed.', '$'     ; объявляем здесь, а не вверху, чтобы эти строки не остались в резидентной части программы (они там не нужны)
    exit_msg db 'New interrupt handler uninstalled.', '$'
    
CSEG ENDS
END main
