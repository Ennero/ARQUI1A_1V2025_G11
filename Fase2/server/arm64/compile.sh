#!/bin/bash

# --- Un script para ensamblar, enlazar y ejecutar código puro de ARM64 para múltiples archivos ---

# Colores para una salida más bonita
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# 1. Verificar si se proporcionó al menos un archivo de entrada
if [ -z "$1" ]; then
    echo -e "${RED}Error: Debes proporcionar al menos un archivo de ensamblador como argumento.${NC}"
    #>> Se actualiza el mensaje de uso para reflejar que puede aceptar múltiples archivos.
    echo "Uso: ./compilar.sh <archivo_principal.s> [archivo2.s] [archivo3.s] ..."
    exit 1
fi

# 2. Definir los nombres de los archivos
#>> El nombre del ejecutable se basará en el *primer* archivo que pases.
MAIN_SOURCE_FILE="$1"
BASE_NAME=$(basename "$MAIN_SOURCE_FILE" .s)
EXECUTABLE_FILE="${BASE_NAME}" #>> Hecho más simple, ej: "main" en lugar de "main_exec"

#>> Variable para almacenar la lista de todos los archivos objeto que se creen.
OBJECT_FILES=""

echo -e "${BLUE}--- Iniciando el proceso de compilación ---${NC}"

# 3. Ensamblar cada archivo .s a su archivo objeto .o correspondiente
#>> Se usa un bucle 'for' para iterar sobre TODOS los argumentos ($@) que se le pasen al script.
for SOURCE_FILE in "$@"; do
    
    echo -e "\n${BLUE}Ensamblando archivo: $SOURCE_FILE...${NC}"
    
    CURRENT_BASE_NAME=$(basename "$SOURCE_FILE" .s)
    CURRENT_OBJECT_FILE="${CURRENT_BASE_NAME}.o"

    aarch64-linux-gnu-as -g -o "$CURRENT_OBJECT_FILE" "$SOURCE_FILE"

    # Verificar si el ensamblado de ESTE archivo falló
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Falló el ensamblado de $SOURCE_FILE. Revisa los errores de sintaxis.${NC}"
        #>> Si un archivo falla, limpiamos los .o que ya se crearon y salimos.
        echo "Limpiando archivos objeto creados..."
        rm -f $OBJECT_FILES
        exit 1
    fi

    echo -e "${GREEN}Ensamblado exitoso. Archivo objeto creado: $CURRENT_OBJECT_FILE${NC}"
    
    #>> Se añade el nuevo archivo objeto a nuestra lista para el enlazador.
    OBJECT_FILES="$OBJECT_FILES $CURRENT_OBJECT_FILE"
done

# 4. Enlazar TODOS los archivos objeto para crear un único ejecutable
echo -e "\n${BLUE}--- Enlazando todos los archivos objeto ---${NC}"
#>> Se le pasa la lista completa de archivos .o al enlazador (ld).
aarch64-linux-gnu-ld -o "$EXECUTABLE_FILE" $OBJECT_FILES

# Verificar si el enlazado falló
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Falló el enlazado.${NC}"
    rm -f $OBJECT_FILES # Limpiar antes de salir
    exit 1
fi

echo -e "${GREEN}Enlazado exitoso. Ejecutable creado: $EXECUTABLE_FILE${NC}"

# 5. Ejecutar el programa final con QEMU
echo -e "\n${BLUE}--- Ejecutando '$EXECUTABLE_FILE' con qemu-aarch64 ---${NC}"
qemu-aarch64 "./$EXECUTABLE_FILE"

# Capturar el código de salida inmediatamente
EXIT_CODE=$?

# 6. Mostrar el resultado
echo -e "\n${GREEN}--- ¡Proceso completado! ---"
echo -e "El código de salida del programa es: ${BLUE}$EXIT_CODE${NC}"

# 7. Limpiar los archivos intermedios
echo -e "\nLimpiando archivos objeto intermedios..."
#>> Se eliminan TODOS los archivos .o que se generaron.
rm $OBJECT_FILES

exit 0