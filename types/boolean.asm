;-------------------------------------------;
; CONVERSION DE STRING A BOOLEANO           ;
; Y LUEGO DE BOOLEANO A STRING              ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
; Descripcion:                              ;
; Este programa pide un valor booleano      ;
; (1 o 0) por medio de la entrada estandar  ;
; y lo convierte a un boolean y luego lo    ;
; convierte a un string para mostrarlo en   ;
; la salida estandar.                       ;
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

	mensaje0 db 10,13,'Introduzca un valor booleano 1 (verdadero) o 0 (Falso) : $'
	mensaje1 db 10,13,'El valor introducido es: $'
	mensajeErrorNoBoolean db 10,13,'Error: No se introdujo un booleano $'
	string db 2, ?
	valor dw 0
    true db '1 (vedadero)$'
    false db '0 (falso)$'

datos endS

codigo segment

; Macro para convertir un string a un valor booleano
; Cualquier valor distinto de 1 o 0 se considera un error
stringtoboolean macro 
    mov bx, 2
	xor ax, ax
	mov al, string[bx]
	sub al, 30h
	cmp al, 1
	ja noBooleanError
	mov valor, ax
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
	mov dx, offset string
	mov ah, 0ah
	int 21h

	; se convierte el string a un numero entero
	stringtoboolean
	
	; Se imprime el mensaje para mostrar el numero introducido
	mov dx, offset mensaje1
	mov ah, 9
	int 21h
	
    ; Se imprime el valor introducido
    cmp valor, 1
    je esVerdadero
    mov dx, offset false
    jmp imprimir

esVerdadero:
    mov dx, offset true

imprimir:
    mov ah, 9
    int 21h
    jmp fin

noBooleanError:
	mov dx, offset mensajeErrorNoBoolean
	mov ah, 9
	int 21h
	jmp fin

fin:
	mov ax, 4c00h 
	int 21h 	 	

codigo endS
end inicio	