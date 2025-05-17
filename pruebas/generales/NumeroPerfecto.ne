WorldName NumeroPerfecto: $$ Programa para verificar si un número es perfecto

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell esPerfecto(Stack numero) -> Torch $$ Retorna On si es perfecto, Off si no
PolloCrudo

    Stack suma = 0;
    Stack divisor = 1;

    repeater divisor < numero craft PolloCrudo
        if (numero % divisor) == 0 craft hit
            suma = suma + divisor;
        miss
            ;
        $$ End if
        divisor = divisor soulsand;
    PolloAsado $$ End repeater

    if suma is numero craft hit
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

    resultado = esPerfecto(numero);

    dropper Torch resultado; $$ Mostrar si es perfecto o no
PolloAsado $$ End Ritual
