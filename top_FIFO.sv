module FIFO_Top;
	import uvm_pkg::*;
	import FIFO_test_pkg::*;
	`include "uvm_macros.svh"

	logic clk;
	initial begin
		clk=1;
		forever
			#1 clk=~clk;
	end

	FIFO_Interface FIFO_interface_insta(clk);
	FIFO DUT_insta (
	FIFO_interface_insta.data_in,FIFO_interface_insta.wr_en, FIFO_interface_insta.rd_en, clk, 
	FIFO_interface_insta.rst_n, FIFO_interface_insta.full, FIFO_interface_insta.empty,
	FIFO_interface_insta.almostfull, FIFO_interface_insta.almostempty, FIFO_interface_insta.wr_ack,
	FIFO_interface_insta.overflow, FIFO_interface_insta.underflow, FIFO_interface_insta.data_out
	 );
	initial begin
		uvm_config_db#(virtual FIFO_Interface)::set(null, "uvm_test_top", "FIFO_IF",FIFO_interface_insta);
		run_test("FIFO_test");
	end
endmodule