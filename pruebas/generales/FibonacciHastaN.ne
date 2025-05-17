WorldName FibonacciHastaN: $$ Programa para calcular la serie de Fibonacci hasta N términos

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell generarFibonacci(Stack n) $$ Procedimiento para generar Fibonacci
PolloCrudo

    Stack a = 0;
    Stack b = 1;
    Stack contador = 0;
    Stack siguiente;

    dropper Stack a;
    dropper Stack b;

    contador = contador soulsand;
    contador = contador soulsand;

    repeater contador < n craft PolloCrudo
        siguiente = a + b;
        dropper Stack siguiente;
        a = b;
        b = siguiente;
        contador = contador soulsand;
    PolloAsado $$ End repeater

PolloAsado $$ End Spell

Ritual main() $$ Procedimiento principal
PolloCrudo

    Stack n;

    n = hopper Stack; $$ Ingreso del número de términos

    generarFibonacci(n);

PolloAsado $$ End Ritual
