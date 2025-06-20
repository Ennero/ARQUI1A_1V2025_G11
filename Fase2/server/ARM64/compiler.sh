aarch64-linux-gnu-as -g ./stats/main.s -o ./stats/main.o
aarch64-linux-gnu-as -g ./stats/mean/mean.s -o ./stats/mean/mean.o
aarch64-linux-gnu-as -g ./stats/sum/sum.s -o ./stats/sum/sum.o
aarch64-linux-gnu-as -g ./stats/print_num/print_num.s -o ./stats/print_num/print_num.o
aarch64-linux-gnu-ld ./stats/main.o ./stats/mean/mean.o ./stats/sum/sum.o ./stats/print_num/print_num.o -o ./stats/main