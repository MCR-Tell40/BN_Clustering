vsim -novopt work.bubble_sort_test_top

add wave -position end  sim:/bubble_sort_test_top/reader_bubble_train
add wave -position end  sim:/bubble_sort_test_top/bubble_sorted_train
add wave -position end  sim:/bubble_sort_test_top/sorted_signal
add wave -position 0  sim:/bubble_sort_test_top/test_clk
add wave -position 1  sim:/bubble_sort_test_top/test_rst
add wave -position end sim:/bubble_sort_test_top/bubbleinst1/*

force -freeze sim:/bubble_sort_test_top/test_clk 1 0, 0 {3125 ps} -r 6.25ns
force -freeze sim:/bubble_sort_test_top/test_rst 1 0
force -freeze sim:/bubble_sort_test_top/test_rst 0 1ns


