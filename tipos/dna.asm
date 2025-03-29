;-------------------------------------------;
; RECIBE UNA CADENA DE DNA Y LUEGO SALE     ;
; POR LA SALIDA ESTANDAR                    ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
; Descripcion:                              ;
; Este programa pide una cadena de DNA      ;
; (G, C, T, A) de un largo de maximo 1000   ; 
; bases por medio de la entrada             ;
; estandar y lo convierte a un boolean y    ;
; luego lo convierte a un string para       ;
; mostrarlo en la salida estandar.          ;
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
Assume CS:codigo, DS:datos


datos segment

	mensaje0 db 10,13,'Introduzca una cadena de dna de maximo 1000 bases : $'
	mensaje1 db 10,13,'El dna introducido es: $'
	mensajeErrorNoDna db 10,13,'Error: No se introdujo una cadena de dna $'
	dna db 16, 16 dup ('0'), '$'
    readedDna db 16 dup (?), '$'
datos endS

codigo segment

; Macro para convertir un string a un valor booleano
; Cualquier valor distinto de 1 o 0 se considera un error
stringtodna macro 
	xor bx, bx
	xor cx, cx
	mov bl, dna[1] ; longitud de la cadena
    inc bx
loopStringtoDna:
	xor ax, ax
	mov al, dna[bx]
	cmp al, 'G'
    je esDna
    cmp al, 'C'
    je esDna
    cmp al, 'T'
    je esDna
    cmp al, 'A'
    je esDna
    jmp noDnaError
esDna:
    mov readedDna[bx], al
    dec bx
    cmp bx, 1
    jne loopStringtoDna
endM

inicio:
;---------------------------------------
;- Aqui va todo el codigo del programa -
;---------------------------------------
	
	; Se cargan los datos definidos en datos Segment
	mov ax, datos
	mov ds, ax		

	; Se imprime el mensaje para pedir un numero 
	mov dx, offset mensaje0
	mov ah, 9
	int 21h

	; se lee un string de la entrada estandar
	mov dx, offset dna
	mov ah, 0ah
	int 21h

	; se confirma que el string sea una cadena de dna
	stringtodna
	
	; Se imprime el mensaje para mostrar la cadena introducida
	mov dx, offset mensaje1
	mov ah, 9
	int 21h
	
    ; Se imprime la cadena introducida
    mov dx, offset readedDna
    add dx, 2
    mov ah, 9
    int 21h
	jmp fin

noDnaError:
	mov dx, offset mensajeErrorNoDna
	mov ah, 9
	int 21h

fin:
	mov ax, 4c00h 
	int 21h 	 	

codigo endS
end inicio	