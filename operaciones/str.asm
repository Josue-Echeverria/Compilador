;-------------------------------------------;
; Ejecuta las operaciones para los strings  ;
;                                           ;
; Creado por: Echeverria Josue              ;
;                                           ;
;-------------------------------------------;
;                                           ;
; Forma de compilacion:                     ;
; Usando el turbo assembler.                ;
;    tasm /zi /l str                        ;
;    tasm /zi /l lib                        ;
;    tlink /v str lib                       ;
;                                           ;
;-------------------------------------------;

extrn stringtoint:Far, print:Far, inttostring:Far, checkStringIndex:Far, input:Far, getStringLength:Far, concatString:Far, findChar:Far, underCutString:Far, booltoint:Far, archivotoint:Far
Assume CS:codigo, DS:datos

datos segment
    mensajeEntradaChar db 10,13,'Introduce un caracter: $'
    mensajeComienzoCorte db 10,13,'Introduzca desde cual posicion desea comenzar el corte: $'
    mensajeLargoCorte db 10,13,'Introduzca la longitud del corte: $'
    mensajeComienzoRecorte db 10,13,'Introduzca desde cual posicion desea comenzar el recorte: $'
    mensajeLargoRecorte db 10,13,'Introduzca la longitud del recorte: $'
    mensajeEntradaString1 db 10,13,'Introduce la primera cadena: $'
    mensajeEntradaString2 db 10,13,'Introduce la segunda cadena: $'
    mensajeConcatenado db 10,13,'Cadenas concatenada: $'
    mensajeLargo db 10,13,'El largo de la cadena 1 es: $'

    mensajeEncontrar db 10,13,'Caracter encontrado en la string 1 en la posicion: $'
    mensajeCortar db 10,13,'Cadena 1 cortada: $'
    mensajeRecortar db 10,13,'Cadena 1 recortada: $'

    string1 db 32, 34 dup(?), 0      ; Primera cadena ingresada
    inicioCorteString db 6, 7 dup( ? )           ; Inicio del corte
    inicioCorte dw ?
    longitudCorteString db 6, 7 dup( ? )   ; Longitud del corte
    longitudCorte dw ?

    inicioRecorteString db 6, 7 dup( ? )           ; Inicio del recorte
    inicioRecorte dw ?
    longitudRecorteString db 6, 7 dup( ? )   ; Longitud del recorte
    longitudRecorte dw ?
    resultadoRecorte db 64 dup('$')


    string2 db 32, 32 dup(?)      ; Primera cadena ingresada
    resultado db 64 dup('$')    
    largo dw 0                 
    posicion dw 0              
    stringfiedInt db 6 dup(?), '$'
    caracter db ?              
datos ends

codigo segment
inicio:
    mov ax, datos
    mov ds, ax

    ; Leer la primera cadena
    push offset mensajeEntradaString1
    call print
    push offset string1
    call input
    push offset mensajeEntradaString2
    call print
    push offset string2
    call input


    ;----------------------------------------
    ; Cortar cadena (R)
    ;----------------------------------------
        ; Pedir posición inicial del corte
        push offset mensajeComienzoCorte
        call print
        push offset inicioCorteString
        call input
        push offset inicioCorteString
        call stringtoint 
        pop ax
        mov inicioCorte, ax

        ; Verificar que la posición inicial no exceda el tamaño de la cadena
        push offset string1
        push offset inicioCorte
        call checkStringIndex

        ; Pedir longitud del corte
        push offset mensajeLargoCorte
        call print
        push offset longitudCorteString
        call input
        push offset longitudCorteString
        call stringtoint
        pop ax
        mov longitudCorte, ax

        ; Verificar que la posición final no exceda el tamaño de la cadena
        push offset string1
        mov ax, inicioCorte
        add longitudCorte, ax ; Hasta donde llega el corte
        push offset longitudCorte
        call checkStringIndex
        mov ax, inicioCorte
        sub longitudCorte, ax ; Se devuelve la longitud del corte
        
        ; Realizar el corte
        lea si, string1 + 2
        add si, inicioCorte         ; Mover a la posición inicial
        lea di, resultado
        mov cx, longitudCorte
        push es
        mov ax, ds
        mov es, ax
    cutLoop:
        cmp cx, 0
        je endCut
        lodsb
        stosb
        dec cx
        jmp cutLoop
    endCut:
        mov al, '$'
        stosb
        pop es
        push offset mensajeCortar
        call print
        push offset resultado
        call print

;----------------------------------------
; Recortar 
;----------------------------------------
    
 ; Pedir posición inicial del corte
        push offset mensajeComienzoRecorte
        call print
        push offset inicioRecorteString
        call input
        push offset inicioRecorteString
        call stringtoint 
        pop ax
        mov inicioRecorte, ax

        ; Verificar que la posición inicial no exceda el tamaño de la cadena
        push offset string1
        push offset inicioRecorte
        call checkStringIndex

        ; Pedir longitud del corte
        push offset mensajeLargoRecorte
        call print
        push offset longitudRecorteString
        call input
        push offset longitudRecorteString
        call stringtoint
        pop ax
        mov longitudRecorte, ax

        ; Verificar que la posición final no exceda el tamaño de la cadena
        push offset string1
        mov ax, inicioRecorte
        add longitudRecorte, ax ; Hasta donde llega el corte
        push offset longitudRecorte
        call checkStringIndex
        mov ax, inicioRecorte
        sub longitudRecorte, ax ; Se devuelve la longitud del corte

        push es
        mov ax, ds
        mov es, ax

        mov ax, offset string1
        add ax, 2
        push ax
        mov ax, inicioRecorte
        push ax
        mov ax, longitudRecorte
        push ax
        push offset resultadoRecorte
        call underCutString

        pop es

        push offset mensajeRecortar
        call print

        push offset resultadoRecorte
        call print

;----------------------------------------
; Concatenar cadenas (R)
;----------------------------------------

        push es
        mov ax, ds
        mov es, ax

        mov bx, offset string1
        add bx, 2
        push bx
        mov bx, offset string2
        add bx, 2
        push bx
        push offset resultado
        call concatString

        pop es
               

        push offset mensajeConcatenado
        call print
        push offset resultado
        call print

;----------------------------------------
; Obtener largo de la primera cadena (R)
;----------------------------------------

    push offset largo 
    mov ax, offset string1
    add ax, 3
    push ax
    call getStringLength


    push offset mensajeLargo
    call print
    
    mov ax, largo
    mov bx, offset stringfiedInt
    add bx, 5
    call inttostring
    push offset stringfiedInt
    call print

;----------------------------------------
; Buscar un carácter en la primera cadena (no R)
; Debuggeandolo, funcion pero al ejecutar no, (imprime una possion incorrecta)
;----------------------------------------

    ; push offset mensajeEntradaChar
    ; call print

    ; mov ah, 01h
    ; int 21h
    ; mov caracter, al
    
    ; mov bx, offset string1
    ; add bx, 2
    ; push bx
    ; xor ax, ax
    ; mov al, caracter
    ; push ax
    ; push offset posicion
    ; call findChar


    ; mov ax, posicion
    ; mov bx, offset stringfiedInt
    ; add bx, 5
    ; call inttostring

    ; push offset mensajeEncontrar
    ; call print

    ; push offset stringfiedInt
    ; call print

continuar:
    ; Finalizar programa
    mov ax, 4c00h
    int 21h
codigo ends
end inicio