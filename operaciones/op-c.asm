;-------------------------------------------;
; Ejecuta lasfunciones para los strings     ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l dna                        ;
;    tasm /zi /l lib                        ;
;    tlink /v dna lib                       ;
;                                           ;
; Fecha de creacion:mayo 16, 2025.          ;
;-------------------------------------------;

extrn print:Far, inttostring:Far, esDigito:Far, esAlpha:Far, toMayuscula:Far, toMinuscula:Far
Assume CS:codigo, DS:datos

datos segment
    mensajeEntradaChar  db 10,13,'Introduce un caracter: $'
    mensajeSalida       db 10,13,'El valor en un entero es: $'
    mensajeEsDigito     db 10,13,'Es un digito: $'
    mensajeEsAlpha      db 10,13,'Es una letra: $'
    mensajeConvertidoMayuscula  db 10,13,'Convertido a mayuscula: $' ; Changed message
    mensajeConvertidoMinuscula  db 10,13,'Convertido a minuscula: $' ; Changed message
    
    respuestaSi         db 'Si',10,13,'$' ; Used by esDigito and esAlpha
    respuestaNo         db 'No',10,13,'$' ; Used by esDigito and esAlpha
    result db ?

    resultUpper db ?, '$' ; Almacena el resultado de la conversion a mayuscula
    resultLower db ?,'$' ; Almacena el resultado de la conversion a minuscula
    char                db ?                  ; Almacena el caracter ingresado
    stringfiedCharInt   db 3 dup(?), '$'      ; Para imprimir el valor entero del caracter
    convertedChar       db ?, '$'             ; Buffer for the converted character
datos ends

codigo segment
inicio:
    mov ax, datos
    mov ds, ax

    ; Leer un caracter
    push offset mensajeEntradaChar
    call print
    xor ax, ax
    mov ah, 01h
    int 21h
    mov char, al


;--------------------------------------------------------------------------------
; --- Verificar si es un dígito ---
;--------------------------------------------------------------------------------
    push offset mensajeEsDigito
    call print

    push offset result
    xor ah, ah
    mov al, char
    push ax
    call esDigito
    
    mov al, result
    cmp al, 0
    je noEsDigito_Print
    ; Es un dígito
    push offset respuestaSi
    call print
    jmp despuesDeDigitoCheck
noEsDigito_Print:
    push offset respuestaNo
    call print
despuesDeDigitoCheck:

;--------------------------------------------------------------------------------
; --- Verificar si es una letra (alpha) ---
;--------------------------------------------------------------------------------
    push offset mensajeEsAlpha
    call print
   
    push offset result
    xor ah, ah
    mov al, char
    push ax
    call esAlpha

    mov al, result
    cmp al, 0
    je noEsAlpha_Print
    ; Es una letra
    push offset respuestaSi
    call print
    jmp despuesDeAlphaCheck
noEsAlpha_Print:
    push offset respuestaNo
    call print
despuesDeAlphaCheck:

;--------------------------------------------------------------------------------
; --||- Convertir a Mayúscula ---
;--------------------------------------------------------------------------------

    push offset mensajeConvertidoMayuscula ; Use new message
    call print
    
    push offset resultUpper
    xor ah, ah
    mov al, char
    push ax
    call toMayuscula

    push offset resultUpper
    call print

;--------------------------------------------------------------------------------
; --- Convertir a Minúscula ---
;--------------------------------------------------------------------------------

    push offset mensajeConvertidoMinuscula ; Use new message
    call print

    push offset resultLower
    xor ah, ah
    mov al, char
    push ax
    call toMinuscula

    push offset resultLower
    call print

    ; Finalizar programa
    mov ax, 4c00h
    int 21h
codigo ends
end inicio