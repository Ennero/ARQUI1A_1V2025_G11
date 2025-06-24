aarch64-linux-gnu-as -g ./menu.s -o ./menu.o
aarch64-linux-gnu-as -g ./readfile/readfile.s -o ./readfile/readfile.o
aarch64-linux-gnu-as -g ./numbers_array/numbers_array.s -o ./numbers_array/numbers_array.o
aarch64-linux-gnu-as -g ./read_opt/read_opt.s -o ./read_opt/read_opt.o
aarch64-linux-gnu-as -g ./create_range_buffer/create_range_buffer.s -o ./create_range_buffer/create_range_buffer.o
aarch64-linux-gnu-as -g ./print/print.s -o ./print/print.o


aarch64-linux-gnu-ld ./menu.o ./readfile/readfile.o ./numbers_array/numbers_array.o ./read_opt/read_opt.o ./create_range_buffer/create_range_buffer.o ./print/print.o -o ./menu

qemu-aarch64 ./menu
