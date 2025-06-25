#!/bin/bash

mkdir -p build  # crea la carpeta build si no existe

# Lista de archivos fuente sin extensión ni carpeta "build"
files=(
  menu
  functions/readfile
  functions/numbers_array
  functions/read_opt
  functions/create_range_buffer
  functions/print
  functions/minimum
  functions/maximum
  functions/itoa
  functions/printNum
  functions/mean
  functions/sum
  functions/bubble_sort
  functions/median
  functions/mode
  functions/sub_var
  functions/variance
  functions/stdev
  functions/writeXML
  functions/exp_smooth
  functions/convert
  functions/exp_smoothXML
  functions/numbers_array2
)

# Compilar cada archivo .s a .o dentro de build
for f in "${files[@]}"; do
  # extraer solo el nombre de archivo sin ruta para el .o
  base=$(basename "$f")
  aarch64-linux-gnu-as -g "./$f.s" -o "./build/$base.o"
done

# Crear la lista de objetos para enlazar
objs=$(printf "./build/%s.o " "${files[@]##*/}")

# Enlazar todos los objetos
aarch64-linux-gnu-ld $objs -o ./menu

qemu-aarch64 ./menu
