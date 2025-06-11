;-------------------------------------------;
; Ejecuta operaciones aritmeticas           ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l int                        ;
;    tasm /zi /l lib                        ;
;    tlink /v int lib                       ;
;                                           ;
;-------------------------------------------;

extrn print:Far, input:Far, stringtoint:Far, inttostring:Far, pluOperand:Far, minOperand:Far, mulOperand:Far, divOperand:Far, modOperand:Far, incOperand:Far, decOperand:Far
Assume CS:codigo, DS:datos

datos segment
    mensajeEntradaNumero1 db 10,13,'Introduzca el primer numero: $'
    mensajeEntradaNumero2 db 10,13,'Introduzca el segundo numero: $'
    numString1 db 6, 7 dup(?), '$'
    numString2 db 6, 7 dup(?), '$'
    num1 dw 0
    num2 dw 0

    resultado dw ?
    
    mensajeSuma db 10,13,'Suma (+): $'
    mensajeResta db 10,13,'Resta (-): $'
    mensajeMultiplicacion db 10,13,'Multiplicacion (*): $'
    mensajeDivision db 10,13,'Division (// cociente): $'
    mensajeModulo db 10,13,'Modulo (% resto): $'
    mensajeIncrementar db 10,13,'Incrementar numero 1: $'
    mensajeDecrementar db 10,13,'Decrementar numero 2: $'

    
    stringResultadoSuma db 6 dup(?), '$'
    stringResultadoResta db 6 dup(?), '$'
    stringResultadoMul db 6 dup(?), '$'
    stringResultadoDiv db 6 dup(?), '$'
    stringResultadoMod db 6 dup(?), '$'
    stringResultadoIncrementar db 6 dup(?), '$'
    stringResultadoDecrementar db 6 dup(?), '$'
datos ends

codigo segment
inicio:
    mov ax, datos
    mov ds, ax

    push offset mensajeEntradaNumero1
    call print

    push offset numString1
    call input

    push offset numString1
	call stringtoint
	pop ax
	mov num1, ax

    push offset mensajeEntradaNumero2
    call print

    push offset numString2
    call input

    push offset numString2
    call stringtoint
    pop ax
    mov num2, ax
    
;----------------------------------------
; Suma (+)
;----------------------------------------
    push offset mensajeSuma
    call print

    mov ax, num2    ; Push second operand
    push ax
    mov ax, num1    ; Push first operand
    push ax
    push offset resultado
    call pluOperand
    
    mov ax, resultado
    mov bx, offset stringResultadoSuma
    add bx, 5       ; Point to end of buffer for inttostring
    call inttostring
    
    push offset stringResultadoSuma
    call print

; ;----------------------------------------
; ; Resta (-)
; ;----------------------------------------

    push offset mensajeResta
    call print

    mov ax, num2    ; Push second operand (subtrahend)
    push ax
    mov ax, num1    ; Push first operand (minuend)
    push ax
    push offset resultado
    call minOperand
    

    mov ax, resultado
    mov bx, offset stringResultadoResta
    add bx, 5
    call inttostring
    
    push offset stringResultadoResta
    call print

; ;----------------------------------------
; ; Multiplicación (*)
; ;----------------------------------------
    push offset mensajeMultiplicacion
    call print

    mov ax, num2
    push ax
    mov ax, num1
    push ax
    push offset resultado
    call mulOperand

    mov ax, resultado
    mov bx, offset stringResultadoMul
    add bx, 5
    call inttostring

    push offset stringResultadoMul
    call print

; ;----------------------------------------
; ; División (//) - Cociente
; ;----------------------------------------
    push offset mensajeDivision
    call print

    mov ax, num2    ; Push second operand (divisor)
    push ax
    mov ax, num1    ; Push first operand (dividend)
    push ax
    push offset resultado
    call divOperand ; Assumed to return quotient in AX

    mov ax, resultado
    mov bx, offset stringResultadoDiv
    add bx, 5
    call inttostring

    push offset stringResultadoDiv 
    call print

; ;----------------------------------------
; ; Modulo (%) - Resto
; ;----------------------------------------
    push offset mensajeModulo

    call print

    mov ax, num2    ; Push second operand (divisor)
    push ax
    mov ax, num1    ; Push first operand (dividend)
    push ax
    push offset resultado
    call modOperand ; Assumed to return remainder in AX

    mov ax, resultado
    mov bx, offset stringResultadoMod
    add bx, 5
    call inttostring
    push offset stringResultadoMod
    call print

; ;----------------------------------------
; ; Incrementar
; ;----------------------------------------
    push offset mensajeIncrementar
    call print


    push offset num1
    call incOperand

    mov ax, num1
    mov bx, offset stringResultadoIncrementar
    add bx, 5
    call inttostring

    push offset stringResultadoIncrementar
    call print
; ;----------------------------------------
; ; Decrementar
; ;----------------------------------------
    push offset mensajeDecrementar
    call print

    push offset num2
    call decOperand

    mov ax, num2
    mov bx, offset stringResultadoDecrementar
    add bx, 5
    call inttostring

    push offset stringResultadoDecrementar
    call print

fin:
    mov ax, 4c00h
    int 21h
codigo ends
end inicio