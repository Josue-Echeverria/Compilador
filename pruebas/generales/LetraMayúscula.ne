WorldName LetraMayuscula: $$ Programa para convertir una letra a mayúscula

Bedrock $$ Constant Section

CraftingTable $$ Routine Section

Spell convertirMayuscula(Rune letra) -> Rune $$ Función para convertir a mayúscula
PolloCrudo

    Rune resultado;

    resultado = upper letra;

    respawn resultado;
PolloAsado $$ End Spell

Ritual main() $$ Procedimiento principal
PolloCrudo

    Rune letra;
    Rune mayuscula;

    letra = hopper Rune; $$ Ingreso de la letra

    mayuscula = convertirMayuscula(letra);

    dropper Rune mayuscula; $$ Mostrar la letra en mayúscula
PolloAsado $$ End Ritual
