;-------------------------------------------;
; Lectura de arhivos                        ;
;-------------------------------------------;
;                                           ;
; Creado por: Quiros Harlen                 ;
;                                           ;
; Descripcion:                              ;
; Este programa pide el nombre de un archivo;
; y muestra su contenido en pantalla.       ;
;                                           ;
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
extrn print:Far, addUpString:Far, inttostring:Far, stringtoint:Far, booltoint:Far
datos Segment
    mensajeEntradaEntero db 10,13,'Introduzca un valor entero: $'
	mensajeEntradaBool db 10,13,'Introduzca un valor booleano (1 | 0): $'
	mensajeEntradaString db 10,13,'Introduce un string: $'
	mensajeEntradaChar db 10,13,'Introduce un caracter: $'
	mensajeEntradaDNA db 10,13,'Introduzca una cadena de DNA: $'
	mensajeSalida db 10,13,'El valor en un archivo se encuentra en : $'
	endOfFileName db ".txt", 0

    string db 32, 32 dup (?)
    archivoNombreString db "s-", 5 dup ('0') 
                        db ".txt", 0, '$'  
    idNombreArchivo dw ?  ; Nombre del archivo
    
    integer dw 0
    stringInt db 6, 6 dup (?),'$'
    archivoNombreInteger db "i-", 5 dup ('0') 
                        db ".txt", 0, '$'

    char db ?
    archivoNombreChar db "c-", 5 dup ('0') 
                        db ".txt", 0, '$'

    bool db ?
    archivoNombreBool db "b-", 5 dup ('0') 
                        db ".txt", 0, '$'
datos EndS





codigo Segment
    assume cs:codigo, ds:datos    

Inicio:
    mov ax, datos
    mov ds, ax

;---------------------------------------
; STRING -> ARCHIVO 
;---------------------------------------

    ; Solicitar nombre del archivo
    push offset mensajeEntradaString
    call print

    ; se lee un string de la entrada estandar
	mov dx, offset string
	mov ah, 0ah
	int 21h

    push offset idNombreArchivo
    push offset string
    call addUpString

    mov ax, idNombreArchivo
    mov bx, offset archivoNombreString
    add bx, 6
    call inttostring

    mov ah, 03ch 			
	xor cx,cx        ; Con cx = 0 se crea un archivo de texto             
	mov dx, offset archivoNombreString  	
	int 21h	

    mov bx, ax
    mov ah, 40h
    mov dx, offset string
    add dx, 2
    mov cl, [string+1]  ; Longitud del string
    int 21h

    mov ah, 3eh
    int 21h

    push offset mensajeSalida
    call print

    push offset archivoNombreString
    call print


;---------------------------------------
; INT -> ARCHIVO 
;---------------------------------------

    
    ; Solicitar nombre del archivo
    push offset mensajeEntradaEntero
    call print

    ; se lee un string de la entrada estandar
    mov dx, offset stringInt
    mov ah, 0ah
    int 21h

    push offset stringInt
    call stringtoint
	pop ax
	mov integer, ax

    mov ax, integer
    mov bx, offset archivoNombreInteger
    add bx, 6
    call inttostring

    mov ah, 03ch 			
    xor cx,cx        ; Con cx = 0 se crea un archivo de texto             
    mov dx, offset archivoNombreInteger  	
    int 21h	

    mov bx, ax
    mov ah, 40h
    mov dx, offset stringInt
    add dx, 2
    mov cl, [stringInt+1]  ; Longitud del string
    int 21h

    mov ah, 3eh
    int 21h

    push offset mensajeSalida
    call print

    push offset archivoNombreInteger
    call print



;---------------------------------------
; CHAR -> ARCHIVO 
;---------------------------------------

    push offset mensajeEntradaChar
    call print

	xor ax, ax
	mov ah, 01h
	int 21h
	mov char, al

    xor ax, ax
    mov al, char
    mov bx, offset archivoNombreChar
    add bx, 6
    call inttostring

    mov ah, 03ch
    xor cx,cx        ; Con cx = 0 se crea un archivo de texto
    mov dx, offset archivoNombreChar
    int 21h

    mov bx, ax
    mov ah, 40h
    mov dx, offset char
    mov cl, 1
    int 21h

    xor ax, ax
    mov ah, 3eh
    int 21h

    push offset mensajeSalida
    call print

    push offset archivoNombreChar
    call print


;---------------------------------------
; BOOL -> ARCHIVO 
;---------------------------------------


    xor ax, ax
    mov ah, 2ch
    int 21h

    mov ax, dx
    mov bx, offset archivoNombreBool
    add bx, 6
    call inttostring

    push offset mensajeEntradaBool
    call print

    xor ax, ax
	mov ah, 01h
	int 21h
	mov bool, al

	push offset bool
	call booltoint


    mov ah, 03ch
    xor cx,cx        ; Con cx = 0 se crea un archivo de texto
    mov dx, offset archivoNombreBool
    int 21h

    mov bx, ax
    mov ah, 40h
    mov dx, offset bool
    mov cl, 1
    int 21h

    xor ax, ax
    mov ah, 3eh
    int 21h

    push offset mensajeSalida
    call print

    push offset archivoNombreBool
    call print


salida:
    mov ax, 4c00h
    int 21h

codigo EndS
End Inicio
