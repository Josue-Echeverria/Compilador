;---------------------------------------------------------------------
; Archivo ensamblador generado automaticamente por el compilador
; Fecha de generacion: 11 de June de 2025, 00:24:33
; Autor del Compilador: Quiros Harlen y Josue Echeverria
; Lenguaje Fuente: Notch Engine
;---------------------------------------------------------------------

pila segment stack 'stack'
    dw 1024 dup(?) ; Tamano de la pila (ej: 1024 palabras = 2KB)
pila ends

Assume CS:codigo, DS:datos, SS:pila

datos segment public 'data'
    VG_a dw 0
    VG_b dw 0
    VG_c dw 0
    VG_d dw 0
    VG_e dw 0
    VG_f dw 0
datos endS

codigo segment public 'code'
inicio_principal:
    ; Inicializar Registros de Segmento
    mov ax, datos
    mov ds, ax
    mov ax, pila
    mov ss, ax   

    mov ax, 5
    mov VG_a, ax
    
    mov ax, 7
    mov VG_b, ax
    
    mov ax, VG_a
    push ax
    mov ax, VG_b
    pop bx
    add bx, ax
    mov ax, bx
    mov VG_c, ax
    
    mov ax, VG_c
    push ax
    mov ax, VG_a
    pop bx
    sub bx, ax
    mov ax, bx
    mov VG_d, ax
    
    mov ax, VG_a
    push ax
    mov ax, VG_b
    pop bx
    imul bx
    mov VG_e, ax
    
    mov ax, VG_e
    push ax
    mov ax, VG_a
    pop bx
    mov cx, ax
    mov ax, bx
    cwd
    idiv cx
    mov VG_f, ax
    

fin_programa:
    mov ah, 4Ch
    xor al, al
    int 21h
codigo endS

end inicio_principal
; --- FIN DEL PROGRAMA GENERADO ---