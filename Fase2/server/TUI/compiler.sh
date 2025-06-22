aarch64-linux-gnu-as -g ./menu.s -o ./menu.o
aarch64-linux-gnu-as -g ./readfile/readfile.s -o ./readfile/readfile.o
aarch64-linux-gnu-as -g ./numbers_array/numbers_array.s -o ./numbers_array/numbers_array.o

aarch64-linux-gnu-ld ./menu.o ./readfile/readfile.o ./numbers_array/numbers_array.o -o ./menu

qemu-aarch64 ./menu
