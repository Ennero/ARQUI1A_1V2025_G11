aarch64-linux-gnu-as -g ./menu.s -o ./menu.o
aarch64-linux-gnu-as -g ./readfile/readfile.s -o ./readfile/readfile.o
aarch64-linux-gnu-as -g ./numbers_array/numbers_array.s -o ./numbers_array/numbers_array.o
aarch64-linux-gnu-as -g ./read_opt/read_opt.s -o ./read_opt/read_opt.o
aarch64-linux-gnu-as -g ./minimum/minimum.s -o ./minimum/minimum.o
aarch64-linux-gnu-as -g ./itoa/itoa.s -o ./itoa/itoa.o
aarch64-linux-gnu-as -g ./printNum/printNum.s -o ./printNum/printNum.o
aarch64-linux-gnu-as -g ./maximum/maximum.s -o ./maximum/maximum.o
aarch64-linux-gnu-as -g ./mean/mean.s -o ./mean/mean.o
aarch64-linux-gnu-as -g ./sum/sum.s -o ./sum/sum.o
aarch64-linux-gnu-as -g ./bubble_sort/bubble_sort.s -o ./bubble_sort/bubble_sort.o
aarch64-linux-gnu-as -g ./median/median.s -o ./median/median.o
aarch64-linux-gnu-as -g ./mode/mode.s -o ./mode/mode.o
aarch64-linux-gnu-as -g ./sub_var/sub_var.s -o ./sub_var/sub_var.o
aarch64-linux-gnu-as -g ./variance/variance.s -o ./variance/variance.o
aarch64-linux-gnu-as -g ./stdev/stdev.s -o ./stdev/stdev.o
aarch64-linux-gnu-as -g ./writeXML/writeXML.s -o ./writeXML/writeXML.o


aarch64-linux-gnu-ld ./menu.o ./readfile/readfile.o ./numbers_array/numbers_array.o ./read_opt/read_opt.o ./minimum/minimum.o ./itoa/itoa.o ./printNum/printNum.o ./maximum/maximum.o ./mean/mean.o ./sum/sum.o ./bubble_sort/bubble_sort.o ./median/median.o ./mode/mode.o ./sub_var/sub_var.o ./variance/variance.o ./stdev/stdev.o ./writeXML/writeXML.o -o ./menu

# To run
qemu-aarch64 ./menu

#To debug
# qemu-aarch64 -g 1234 ./menu
