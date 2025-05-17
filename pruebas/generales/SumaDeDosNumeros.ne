WorldName SumaDeDosNumeros: $$ Programa para sumar dos números

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell sumar(Stack a, Stack b) -> Stack $$ Función que suma dos números
PolloCrudo

    Stack resultado;
    resultado = a + b;

    respawn resultado;
PolloAsado $$ End Spell

Ritual main() $$ Procedimiento principal
PolloCrudo

    Stack num1;
    Stack num2;
    Stack suma;

    num1 = hopper Stack; $$ Ingreso del primer número
    num2 = hopper Stack; $$ Ingreso del segundo número

    suma = sumar(num1, num2);

    dropper Stack suma; $$ Mostrar la suma
PolloAsado $$ End Ritual