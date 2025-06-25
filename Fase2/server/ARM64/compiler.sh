#!/bin/bash

mkdir -p build  # crea la carpeta build si no existe

# Lista de archivos fuente sin extensión ni carpeta "build"
files=(
  main
  stats/itoa
  stats/print
  stats/mean
  stats/sum
  stats/sub_var
  stats/variance
  stats/stdev
  stats/mode
  stats/numbers_array
  stats/bubble_sort
  stats/median
  stats/minimum
  stats/maximum
  stats/exp_smooth
)

# Compilar cada archivo .s a .o dentro de build
for f in "${files[@]}"; do
  # extraer solo el nombre de archivo sin ruta para el .o
  base=$(basename "$f")
  as -g "./$f.s" -o "./build/$base.o"
done

# Crear la lista de objetos para enlazar
objs=$(printf "./build/%s.o " "${files[@]##*/}")

# Enlazar todos los objetos
ld $objs -o ./main
