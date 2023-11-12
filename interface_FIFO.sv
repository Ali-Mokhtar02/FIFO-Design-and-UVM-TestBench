interface FIFO_Interface (clk);
import FIFO_shared_pkg::*;

	input logic clk;

	logic [FIFO_WIDTH-1:0] data_in;
	logic wr_en , rd_en, rst_n, full, almostfull,empty;
	logic almostempty, overflow, underflow, wr_ack;
	logic [FIFO_WIDTH-1:0] data_out;

endinterface