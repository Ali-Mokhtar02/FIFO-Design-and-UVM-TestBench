////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(data_in, wr_en, rd_en, clk, rst_n, full, empty, almostfull, almostempty, wr_ack, overflow, underflow, data_out);
parameter FIFO_WIDTH=16;
parameter FIFO_DEPTH=32; ;
input [FIFO_WIDTH-1:0] data_in;
input clk, rst_n, wr_en, rd_en;
output reg [FIFO_WIDTH-1:0] data_out;
output reg wr_ack, overflow,underflow;
output full, empty, almostfull, almostempty;

localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wr_ptr <= 0;
		wr_ack<=0; //give reset value to sequential output
		overflow<=0; // give reset value to overflow sequential output
	end
	else if (wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		overflow<=0;    // if write operation is successfull no overflow happened
	end
	else begin 
		wr_ack <= 0; 
		if (full && wr_en)
			overflow <= 1;
		else
			overflow <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr <= 0;
		data_out<=0; //data_out was not given a reset value
		underflow<=0; // give rest value to underflow sequential output
	end
	else begin
	if (rd_en && count != 0) begin
		data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		underflow<=0;
	end
	if(rd_en && empty)
		underflow<=1;
	else
		underflow<=0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({wr_en, rd_en} == 2'b10) && !full) 
			count <= count + 1;
		else if ( ({wr_en, rd_en} == 2'b01) && !empty)
			count <= count - 1;
		else if( {wr_en, rd_en} ==2'b11) begin // added
			if(full)
				count<=count-1;
			if(empty)
				count<=count+1;
		end
	end
end

assign full = (count == FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;
// assign underflow = (empty && rd_en)? 1 : 0; underflow is used as combinational output when it is specficed as sequential
assign almostfull = (count == FIFO_DEPTH-1)? 1 : 0;  //almost full flag should be high when count==fifodepth-1
assign almostempty = (count == 1)? 1 : 0;

`ifdef enable_assertions
	property Fullp;
		@(posedge clk) disable iff(~rst_n) count==FIFO_DEPTH |-> (full && ~empty && ~almostempty && ~almostfull) ;
	endproperty
	Fullap: assert property(Fullp);
	Fullcp: cover property(Fullp);

	property almostfullp;
		@(posedge clk) disable iff(~rst_n) count==(FIFO_DEPTH-1) |-> (almostfull && ~full && ~empty && ~almostempty) ;
	endproperty
	almostfullap: assert property(almostfullp);
	almostfullcp: cover property(almostfullp);

	property almostemptyp;
		@(posedge clk) disable iff(~rst_n) count==1 |-> (almostempty && ~full && ~empty && ~almostfull);
	endproperty
	almostemptyap: assert property(almostemptyp);
	almostemptycp: cover property(almostemptyp);

	property EmptyP;
		@(posedge clk) disable iff(~rst_n) count==0 |-> (empty && ~full && ~almostempty && ~almostfull) ;
	endproperty
	Emptyap: assert property(EmptyP);
	Emptycp: cover property(EmptyP);

	property Overflowp;
		@(posedge clk) disable iff(~rst_n) (full && wr_en) |=> (overflow) ;
	endproperty
	Overflowap: assert property(Overflowp);
	Overflowcp: cover property(Overflowp);

	property UnderFlowp;
	 	@(posedge clk) disable iff(~rst_n) (empty && rd_en) |=> (underflow);
 	endproperty
	UnderFlowap: assert property(UnderFlowp);
	UnderFlowcp: cover property(UnderFlowp);

	property wr_ackp;
 		@(posedge clk) disable iff(~rst_n) (wr_en && !full) |=> (wr_ack) ;
 	endproperty
	wr_ackap: assert property(wr_ackp);
	wr_ackcp: cover property(wr_ackp);

	//internal counter assertions
	property countincrement;
		logic[max_fifo_addr:0] old_count;
		@(posedge clk) disable iff(~rst_n) (wr_en && ~rd_en && ~full,old_count=count) |=> (count==old_count+1)
	endproperty
	countincrementap: assert property (countincrement);
	countincrementcp: cover property (countincrement);

	property countdecrement;
		logic[max_fifo_addr:0] old_count;
		@(posedge clk) disable iff(~rst_n) (~wr_en && rd_en && ~empty,old_count=count) |=> (count==old_count-1)
	endproperty
	countdecrementap: assert property (countdecrement);
	countdecrementcp: cover property (countdecrement);

	property countstable;
		logic[max_fifo_addr:0] old_count;
		@(posedge clk) disable iff(~rst_n) (wr_en && rd_en && ~full && ~empty) |=> $stable(count);
	endproperty
	countstableap: assert property (countstable);
	countstablecp: cover property (countstable);	

	property count_inc_rd_wr;
		logic[max_fifo_addr:0] old_count;
		@(posedge clk) disable iff(~rst_n) (wr_en && rd_en && ~full && empty,old_count=count) |=> (count==old_count+1);
	endproperty
	count_inc_rd_wrap: assert property (count_inc_rd_wr);
	count_inc_rd_wrcp: cover property (count_inc_rd_wr);	

	property count_dec_rd_wr;
		logic[max_fifo_addr:0] old_count;
		@(posedge clk) disable iff(~rst_n) (wr_en && rd_en && full,old_count=count) |=> (count==old_count-1) ;
	endproperty
	count_dec_rd_wrap: assert property (count_dec_rd_wr);
	count_dec_rd_wrcp: cover property (count_dec_rd_wr);	

	property read_pointer_inc;
		logic[$clog2(FIFO_DEPTH)-1:0] old_read;
		@(posedge clk) disable iff(~rst_n) (rd_en && ~empty,old_read=rd_ptr) |=> (rd_ptr==old_read+1'b1) 
	endproperty
	read_pointer_incap: assert property (read_pointer_inc);
	read_pointer_inccp: cover property (read_pointer_inc);

	property read_pointer_stable;
		@(posedge clk) disable iff(~rst_n) (rd_en && empty) |=> $stable(rd_ptr);
	endproperty
	read_pointer_stableap: assert property (read_pointer_stable);
	read_pointer_stablecp: cover property (read_pointer_stable);

	property write_pointer_inc;
		logic[$clog2(FIFO_DEPTH)-1:0] old_write;
		@(posedge clk) disable iff(~rst_n) (wr_en && ~full,old_write=wr_ptr) |=> (wr_ptr==old_write+1'b1);
	endproperty
	write_pointer_incap: assert property (write_pointer_inc);
	write_pointer_inccp: cover property (write_pointer_inc);


	property write_pointer_stable;
 		@(posedge clk) disable iff(~rst_n) (wr_en && full) |=> ($stable(wr_ptr));
 	endproperty
	write_pointer_stableap: assert property (write_pointer_stable);
	write_pointer_stablecp: cover property (write_pointer_stable);
`endif

endmodule

