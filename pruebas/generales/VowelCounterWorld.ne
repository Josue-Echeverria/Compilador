WorldName VowelCounterWorld: $$ Entrada del programa

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell countVocal(Spider :: palabra) -> Stack $$ Definición de la función: Integer
PolloCrudo

    Stack index = 0; $$ Integer: índice de la palabra
    Stack fin_index; $$ Integer: longitud de la palabra
    Stack conteo = 0; $$ Integer: conteo de vocales

fin_index = #palabra; $$ Longitud String: # for length

repeater index < fin_index craft PolloCrudo $$ While loop: repeater...craft
    Spider charAtIndex;

    charAtIndex = palabra[index]; $$ Acceso de String : string[index]
    charAtIndex = upper charAtIndex ; $$ Operación de carácter: upper

    jukebox charAtIndex craft , $$ Switch: jukebox...craft
        disc "A" : conteo = conteo soulsand, $$ Incremento de conteo
        disc "E" : conteo = conteo soulsand,
        disc "I" : conteo = conteo soulsand,
        disc "O" : conteo = conteo soulsand,
        disc "U" : conteo = conteo soulsand,
        silence; $$ Default: silence (no action)
    $$ End jukebox

    index = index soulsand; $$ Incremento de index
PolloAsado $$ End repeater

respawn conteo ; $$ respawn: respawn
PolloAsado $$ End Spell

Ritual main() $$ Procedure: Ritual
PolloCrudo

    Spider palabra; $$ String: entrada de la palabra
    Stack total; $$ Integer: resultado del conteo de vocales

palabra = hopper Spider; $$ Input: hopper Spider() (ingresa la palabra)
