WorldName PalabrasIguales: $$ Programa para verificar si dos palabras son iguales

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell sonIguales(Spider palabra1, Spider palabra2) -> Torch $$ Retorna On si son iguales, Off si no
PolloCrudo

    if palabra1 is palabra2 craft hit
        respawn On;
    miss
        respawn Off;
    $$ End if

PolloAsado $$ End Spell

Ritual main() $$ Procedimiento principal
PolloCrudo

    Spider palabra1;
    Spider palabra2;
    Torch resultado;

    palabra1 = hopper Spider; $$ Ingreso de la primera palabra
    palabra2 = hopper Spider; $$ Ingreso de la segunda palabra

    resultado = sonIguales(palabra1, palabra2);

    dropper Torch resultado; $$ Mostrar si son iguales o no
PolloAsado $$ End Ritual
