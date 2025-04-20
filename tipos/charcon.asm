;-------------------------------------------;
; CONVERSION DE CARACTER A TIPOS PRIMITIVOS ;
;                                           ;
; Creado por: Harlen Quirós                 ;
; Descripción: Convierte un caracter dado a ;
; entero, cadena, booleano y conjunto usando;
; procedimientos de la librería externa.    ;
;-------------------------------------------;

extrn print:Far, inttostring:Far
assume CS:codigo, DS:datos

datos segment

    mensajeEntradaChar db 10,13,'Introduce un caracter: $'
    mensajeAscii db 10,13,'Valor ASCII del caracter: $'
    mensajeString db 10,13,'Cadena del caracter: $'
    mensajeBoolean db 10,13,'Valor booleano del caracter: $'
    mensajeConjunto db 10,13,'Conjunto formado por el caracter: $'

    trueMsg db '1 $', 0
    falseMsg db '0 $', 0

    char db ?
    asciiString db 6 dup(?), '$'
    stringChar db 2 dup('$')
    conjuntoString db '{ ', ?, ' }', '$'

datos ends

codigo segment

inicio:
    ; Inicializar segmentos
    mov ax, datos
    mov ds, ax

    ; Leer el caracter desde teclado
    push offset mensajeEntradaChar
    call print

    mov ah, 01h
    int 21h
    mov char, al

    ; --------------------------------------------
    ; Conversión a entero (ASCII)
    ; --------------------------------------------
    push offset mensajeAscii
    call print

    movzx ax, char
    mov bx, offset asciiString
    add bx, 5
    call inttostring

    push offset asciiString
    call print

    ; --------------------------------------------
    ; Conversión a cadena
    ; --------------------------------------------
    push offset mensajeString
    call print

    mov stringChar[0], char
    mov stringChar[1], '$'

    push offset stringChar
    call print

    ; --------------------------------------------
    ; Conversión a booleano (1 si es 'K' o 'k')
    ; --------------------------------------------
    push offset mensajeBoolean
    call print

    mov al, char
    cmp al, 'K'
    je esTrue
    cmp al, 'k'
    je esTrue
    jmp esFalse

esTrue:
    push offset trueMsg
    call print
    jmp seguir

esFalse:
    push offset falseMsg
    call print

seguir:

    ; --------------------------------------------
    ; Conversión a conjunto
    ; --------------------------------------------
    push offset mensajeConjunto
    call print

    mov conjuntoString[2], char
    push offset conjuntoString
    call print

    ; Fin del programa
    mov ax, 4c00h
    int 21h

codigo ends
end inicio