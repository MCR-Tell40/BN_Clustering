vsim -novopt work.bubble_sort_test_top
config wave -signalnamewidth 1
add wave -noupdate -divider Testing\ Top\ Unit

add wave -position end  sim:/bubble_sort_test_top/reader_bubble_train_out
add wave -position end  sim:/bubble_sort_test_top/sorted_data_out
add wave -position end  sim:/bubble_sort_test_top/flagged_data_out

add wave -noupdate -divider Bubble\ Sort\ Controler

add wave -position end  sim:/bubble_sort_test_top/process_complete
add wave -position end  sim:/bubble_sort_test_top/test_clk
add wave -position end  sim:/bubble_sort_test_top/test_rst

add wave -noupdate -divider Counter

add wave -position end  sim:/bubble_sort_test_top/bubbleinst1/counter_reset_global
add wave -position end  sim:/bubble_sort_test_top/bubbleinst1/counter_value

add wave -noupdate -divider Sorting\ Signals

add wave -position end sim:/bubble_sort_test_top/bubbleinst1/Router_Control
add wave -position end sim:/bubble_sort_test_top/bubbleinst1/Control_Bubblesort
add wave -position end sim:/bubble_sort_test_top/bubbleinst1/BubbleSortInst1/inter_reg
add wave -position end sim:/bubble_sort_test_top/bubbleinst1/Bubblesort_Control
add wave -position end sim:/bubble_sort_test_top/bubbleinst1/Control_DataOut

add wave -position end sim:/bubble_sort_test_top/bubbleinst1/Control_Parity

force -freeze sim:/bubble_sort_test_top/test_clk 1 0, 0 {3125 ps} -r 6.25ns
force -freeze sim:/bubble_sort_test_top/test_rst 1 0
force -freeze sim:/bubble_sort_test_top/test_rst 0 23ns


