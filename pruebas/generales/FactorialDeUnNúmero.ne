WorldName FactorialNumero: $$ Programa para calcular el factorial de un número

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell factorial(Stack numero) -> Stack $$ Definición de la función: Retorna factorial
PolloCrudo

    Stack resultado = 1;
    Stack contador = 1;

    repeater contador <= numero craft PolloCrudo
        resultado = resultado * contador;
        contador = contador soulsand;
    PolloAsado $$ End repeater

    respawn resultado;
PolloAsado $$ End Spell

Ritual main() $$ Procedimiento principal
PolloCrudo

    Stack numero;
    Stack respuesta;

    numero = hopper Stack; $$ Ingreso del número a calcular factorial

    respuesta = factorial(numero);

    dropper Stack respuesta; $$ Mostrar el factorial
PolloAsado $$ End Ritual