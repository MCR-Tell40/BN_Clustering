
add wave -position end  sim:/bubblesortcontroller/global_rst
add wave -position end  sim:/bubblesortcontroller/global_clk_160MHz
add wave -position end  sim:/bubblesortcontroller/router_data_in
add wave -position end  sim:/bubblesortcontroller/sorted_data_out
add wave -position end  sim:/bubblesortcontroller/Router_Control
add wave -position end  sim:/bubblesortcontroller/BubbleSort_Control
add wave -position end  sim:/bubblesortcontroller/Control_DataOut
add wave -position end  sim:/bubblesortcontroller/Control_BubbleSort
add wave -position end  sim:/bubblesortcontroller/Control_Parity
add wave -position end  sim:/bubblesortcontroller/Control_RST
add wave -position end  sim:/bubblesortcontroller/RST_Control
add wave -position end  sim:/bubblesortcontroller/reset_patten_spp
add wave -position end  sim:/bubblesortcontroller/reset_patten_train


force -freeze sim:/bubblesortcontroller/global_clk_160MHz 1 0, 0 {3125 ps} -r 6.25ns
force -freeze sim:/bubblesortcontroller/global_rst 1 0
force -freeze sim:/bubblesortcontroller/global_rst 0 1ns


