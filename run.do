vlib work
vlog -f Compile.txt  
vsim -voptargs=+acc work.FIFO_Top  -classdebug -uvmcontrol=all +cover -cover
add wave /FIFO_Top/FIFO_interface_insta/*
add wave /FIFO_Top/DUT_insta/almostemptyap /FIFO_Top/DUT_insta/almostfullap /FIFO_Top/DUT_insta/count_dec_rd_wrap /FIFO_Top/DUT_insta/count_inc_rd_wrap /FIFO_Top/DUT_insta/countdecrementap /FIFO_Top/DUT_insta/countincrementap /FIFO_Top/DUT_insta/countstableap /FIFO_Top/DUT_insta/Emptyap /FIFO_Top/DUT_insta/Fullap /FIFO_Top/DUT_insta/Overflowap /FIFO_Top/DUT_insta/read_pointer_incap /FIFO_Top/DUT_insta/read_pointer_stableap /FIFO_Top/DUT_insta/UnderFlowap /FIFO_Top/DUT_insta/wr_ackap /FIFO_Top/DUT_insta/write_pointer_incap /FIFO_Top/DUT_insta/write_pointer_stableap
run 0
add wave -position insertpoint  \
sim:/uvm_root/uvm_test_top/FIFO_test_env/FIFO_env_agent/FIFO_agent_driver/stim_seq_item
coverage save FIFO.ucdb -du FIFO -onexit
run -all
coverage report -detail -cvg -directive -comments -output fcover_FIFO.txt
