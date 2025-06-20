aarch64-linux-gnu-as -g ./stats/main.s -o ./stats/main.o
aarch64-linux-gnu-as -g ./stats/mean/mean.s -o ./stats/mean/mean.o
aarch64-linux-gnu-as -g ./stats/sum/sum.s -o ./stats/sum/sum.o
aarch64-linux-gnu-as -g ./stats/print_num/print_num.s -o ./stats/print_num/print_num.o
aarch64-linux-gnu-as -g ./stats/sub_var/sub_var.s -o ./stats/sub_var/sub_var.o
aarch64-linux-gnu-as -g ./stats/variance/variance.s -o ./stats/variance/variance.o
aarch64-linux-gnu-as -g ./stats/stdev/stdev.s -o ./stats/stdev/stdev.o
aarch64-linux-gnu-ld ./stats/main.o ./stats/mean/mean.o ./stats/sum/sum.o ./stats/print_num/print_num.o ./stats/sub_var/sub_var.o ./stats/variance/variance.o ./stats/stdev/stdev.o -o ./stats/main