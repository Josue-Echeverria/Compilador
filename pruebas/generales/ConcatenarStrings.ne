WorldName ConcatenarStrings: $$ Programa para concatenar dos strings

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell concatenar(Spider s1, Spider s2) -> Spider $$ Función para concatenar dos cadenas
PolloCrudo

    Spider resultado;

    resultado = s1 bind s2;

    respawn resultado;
PolloAsado $$ End Spell

Ritual main() $$ Procedimiento principal
PolloCrudo

    Spider palabra1;
    Spider palabra2;
    Spider combinado;

    palabra1 = hopper Spider; $$ Ingreso de la primera palabra
    palabra2 = hopper Spider; $$ Ingreso de la segunda palabra

    combinado = concatenar(palabra1, palabra2);

    dropper Spider combinado; $$ Mostrar el string concatenado
PolloAsado $$ End Ritual
