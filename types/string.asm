;-------------------------------------------;
; RECIBE UNA CADENA DE TEXTP Y LUEGO SALE   ;
; POR LA SALIDA ESTANDAR                    ;
;                                           ;
; Creado por: Quiros Harlen                 ;
;                                           ;
; Descripcion:                              ;
; Este programa recibe una cadena de texto, ; 
;   la almacena en un buffer para luego     ;
;    mostrarla en la salida estandar.       ;
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

    mensaje0 db 10,13,'Introduzca una cadena de texto: $'
    mensaje1 db 10,13,'La cadena introducida es: $'
    buffer db 255   ; Tamaño máximo del buffer
    longitud db 0   ; Longitud de la cadena ingresada
    cadena db 255 dup('$'),'$' ; Espacio para la cadena ingresada

datos ends

codigo segment
    assume cs:codigo, ds:datos

inicio:
    ; Cargar el segmento de datos
    mov ax, datos
    mov ds, ax

    ; Mostrar mensaje de solicitud de cadena
    mov dx, offset mensaje0
    mov ah, 9
    int 21h

    ; Preparar buffer para entrada de cadena
    mov dx, offset buffer
    mov ah, 0Ah
    int 21h
  
    ; Mostrar mensaje antes de la cadena
    mov dx, offset mensaje1
    mov ah, 9
    int 21h

    ; Imprimir la cadena ingresada
    mov dx, offset cadena
    mov ah, 9
    int 21h

    ; Terminar el programa
    mov ax, 4c00h
    int 21h

codigo ends
end inicio