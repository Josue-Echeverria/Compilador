WorldName NumeroAleatorio: $$ Programa para generar un número aleatorio entre dos límites

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell generarAleatorio(Stack min, Stack max) -> Stack $$ Función para generar número aleatorio
PolloCrudo

    Stack aleatorio;

    aleatorio = min + (random % (max - min + 1));

    respawn aleatorio;
PolloAsado $$ End Spell

Ritual main() $$ Procedimiento principal
PolloCrudo

    Stack minimo;
    Stack maximo;
    Stack resultado;

    minimo = hopper Stack; $$ Ingreso del límite inferior
    maximo = hopper Stack; $$ Ingreso del límite superior

    resultado = generarAleatorio(minimo, maximo);

    dropper Stack resultado; $$ Mostrar el número aleatorio generado
PolloAsado $$ End Ritual
