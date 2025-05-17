;-------------------------------------------;
; Ejecuta las operaciones para los booleanos;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l bool                       ;
;    tasm /zi /l lib                        ;
;    tlink /v bool lib                      ;
;                                           ;
;-------------------------------------------;

extrn print:Far, booltoint:Far, orOperand:Far, andOperand:Far, xorOperand:Far, notOperand:Far
Assume CS:codigo, DS:datos

datos segment
    mensajeEntradaBool1 db 10,13,'Introduzca el primer valor booleano (0 o 1): $'
    mensajeEntradaBool2 db 10,13,'Introduzca el segundo valor booleano (0 o 1): $'
    mensajeResultadoOr  db 10,13,'Resultado OR: $'
    mensajeResultadoAnd db 10,13,'Resultado AND: $'
    mensajeResultadoXor db 10,13,'Resultado XOR: $'
    mensajeResultadoNot db 10,13,'Resultado NOT (del segundo valor): $'
    
    bool1 db ?               ; Almacena el primer valor booleano ingresado (caracter)
    bool2 db ?               ; Almacena el segundo valor booleano ingresado (caracter)
    resultadoChar db ' ', '$'  ; Para imprimir el resultado ('0' o '1')
datos ends

codigo segment
inicio:
    mov ax, datos
    mov ds, ax

    ; Leer el primer valor booleano
    push offset mensajeEntradaBool1
    call print
    xor ax, ax
    mov ah, 01h
    int 21h
    mov bool1, al
    push offset bool1
    call booltoint
    mov bool1, al


    ; Leer el segundo valor booleano
    push offset mensajeEntradaBool2
    call print
    xor ax, ax
    mov ah, 01h
    int 21h
    mov bool2, al
    push offset bool2
    call booltoint
    mov bool2, al


    ; --- OPERACION OR ---
    xor ah, ah
    mov al, bool1
    push ax
    mov al, bool2
    push ax
    push offset resultadoChar
    call orOperand


    push offset mensajeResultadoOr
    call print
    push offset resultadoChar
    call print

    ; --- OPERACION AND ---
    xor ah, ah
    mov al, bool1
    push ax
    mov al, bool2
    push ax
    push offset resultadoChar
    call andOperand


    push offset mensajeResultadoAnd
    call print
    push offset resultadoChar
    call print

    ; --- OPERACION XOR ---
    xor ah, ah
    mov al, bool1
    push ax
    mov al, bool2
    push ax
    push offset resultadoChar
    call xorOperand

    push offset mensajeResultadoXor
    call print
    push offset resultadoChar
    call print

    ; --- OPERACION NOT (sobre el primer valor, bh) ---
    xor ah, ah
    mov al, bool2
    push ax
    push offset resultadoChar
    call notOperand

    push offset mensajeResultadoNot
    call print
    push offset resultadoChar
    call print

    ; Finalizar programa
    mov ax, 4c00h
    int 21h
codigo ends
end inicio