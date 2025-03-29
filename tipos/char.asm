;-------------------------------------------;
; Almacenamiento de un caracter             ;
;-------------------------------------------;
;                                           ;
; Creado por: Quiros Harlen                 ;
;                                           ;
; Descripcion:                              ;
; Este programa pide un caracter, lo guarda ;
; y luego lo muestra en la salida estandar. ;        ;
;                                           ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l int                        ;
;    tlink /v int                           ;
;                                           ;
; Fecha de creacion: Marzo 03, 2025.        ;
;-------------------------------------------;
datos segment

    mensaje0 db 10,13,'Introduzca un caracter: $'
    mensaje1 db 10,13,'El caracter introducido es: $'
    caracter db ?

datos ends

codigo segment
    assume cs:codigo, ds:datos

inicio:
    ; Cargar el segmento de datos
    mov ax, datos
    mov ds, ax

    ; Se muestra el mensaje de solicitud de caracter
    mov dx, offset mensaje0
    mov ah, 9
    int 21h

    ; Se lee un caracter desde la entrada estándar
    mov ah, 1
    int 21h
    mov caracter, al  ; Guardar el caracter ingresado

    ; Se imprime el mensaje de caracter ingresado
    mov dx, offset mensaje1
    mov ah, 9
    int 21h

    ; Imprime el caracter ingresado
    mov dl, caracter
    mov ah, 2
    int 21h

    ; Termina el programa
    mov ax, 4c00h
    int 21h

codigo ends
end inicio
