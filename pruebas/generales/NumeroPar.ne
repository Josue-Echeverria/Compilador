WorldName NumeroPar: $$ Programa para verificar si un número es par

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell esPar(Stack numero) -> Torch $$ Retorna On si es par, Off si no
PolloCrudo

    target (numero % 2) == 0 craft hit
        respawn On;
    miss
        respawn Off;
    $$ End if

PolloAsado $$ End Spell

Ritual main() $$ Procedimiento principal
PolloCrudo

    Stack numero;
    Torch resultado;

    numero = hopper Stack; $$ Ingreso del número

    resultado = esPar(numero);

    dropper Torch resultado; $$ Mostrar si es par
PolloAsado $$ End Ritual
