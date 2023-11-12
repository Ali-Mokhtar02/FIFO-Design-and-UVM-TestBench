package FIFO_scoreboard_pkg;
	import uvm_pkg::*;
	import FIFO_seq_item_pkg::*;
	import FIFO_shared_pkg::*;
	`include "uvm_macros.svh"
	
	class FIFO_scoreboard extends  uvm_scoreboard;
		`uvm_component_utils(FIFO_scoreboard);
		uvm_analysis_export #(FIFO_seq_item) sb_exp;
		uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
		FIFO_seq_item FIFO_sb_seq_item;

		int error_count=0;
		int correct_count=0;

		logic full_exp, almostfull_exp, empty_exp;
		logic almostempty_exp, overflow_exp, underflow_exp, wr_ack_exp;
		logic [FIFO_WIDTH-1:0] data_out_exp; 

		logic [$clog2(FIFO_DEPTH) -1 :0] read_pointer,write_pointer;
		int stored_elements;
		logic [FIFO_WIDTH-1:0] mem_ref [FIFO_DEPTH-1:0];


		task compare_outputs();
			if(full_exp!==FIFO_sb_seq_item.full || almostempty_exp!==FIFO_sb_seq_item.almostempty
			|| empty_exp!==FIFO_sb_seq_item.empty || overflow_exp!== FIFO_sb_seq_item.overflow
			|| underflow_exp!==FIFO_sb_seq_item.underflow || wr_ack_exp!==FIFO_sb_seq_item.wr_ack 
			|| data_out_exp!== FIFO_sb_seq_item.data_out || almostfull_exp!== FIFO_sb_seq_item.almostfull)
			begin
				error_count++;
				if(full_exp!==FIFO_sb_seq_item.full || almostfull_exp!== FIFO_sb_seq_item.almostfull)
					$display("Error with DUT when comparing with reference model for full flags at time %0t",$time);
				if(almostempty_exp!==FIFO_sb_seq_item.almostempty || empty_exp!==FIFO_sb_seq_item.empty)
					$display("Error with DUT when comparing with reference model for empty flags at time %0t",$time);
				if(  overflow_exp!== FIFO_sb_seq_item.overflow || underflow_exp!==FIFO_sb_seq_item.underflow )
					$display("Error with DUT when comparing with reference model for over/underflow flags at time %0t",$time);
				if(wr_ack_exp!==FIFO_sb_seq_item.wr_ack || data_out_exp!== FIFO_sb_seq_item.data_out)
					$display("Error with DUT when comparing with reference model for wr_ack or FIFO_sb_seq_item_out at time %0t",$time);
			end
			else
				correct_count++;

		endtask: compare_outputs

		function void golden_model();
			if(~FIFO_sb_seq_item.rst_n) begin
				data_out_exp=0;
				full_exp=0;
				almostfull_exp=0;
				empty_exp=1; // Reset FIFO has no elements so empty is asserted
				almostempty_exp=0;
				overflow_exp=0;
				underflow_exp=0;
				wr_ack_exp=0;
				stored_elements=0;
				read_pointer=0;
				write_pointer=0;
			end
			else begin
				fork
					//write
					begin
						if(FIFO_sb_seq_item.wr_en && !full_exp) begin
							mem_ref[write_pointer]=FIFO_sb_seq_item.data_in;
							wr_ack_exp=1;
							overflow_exp=0;
							write_pointer++;
							stored_elements++;
						end
						else if(FIFO_sb_seq_item.wr_en && full_exp) begin
							overflow_exp=1;
							wr_ack_exp=0;
						end
						else begin
							overflow_exp=0;
							wr_ack_exp=0;
						end
					end
					//read
					begin
						if(FIFO_sb_seq_item.rd_en && !empty_exp) begin
							data_out_exp= mem_ref[read_pointer];
							read_pointer++;
							stored_elements--;
							underflow_exp=0;
						end
						else if(FIFO_sb_seq_item.rd_en && empty_exp)
							underflow_exp=1;
						else
							underflow_exp=0;
					end
				join
				if(stored_elements==0)
					empty_exp=1;
				else
					empty_exp=0;
				if(stored_elements==1)
					almostempty_exp=1;
				else
					almostempty_exp=0;
				if(stored_elements==FIFO_DEPTH)
					full_exp=1;
				else
					full_exp=0;
				if(stored_elements==FIFO_DEPTH-1)
					almostfull_exp=1;
				else
					almostfull_exp=0;
			end
		endfunction: golden_model


		function  new(string name="FIFO_scoreboard", uvm_component parent=null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sb_exp= new("sb_exp",this);
			sb_fifo= new("sb_fifo",this);
		endfunction: build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			sb_exp.connect(sb_fifo.analysis_export);

		endfunction: connect_phase

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				sb_fifo.get(FIFO_sb_seq_item);
				golden_model();
				compare_outputs();
			end
		endtask : run_phase

		function void report_phase(uvm_phase phase);
			super.report_phase(phase);
			`uvm_info("report_phase",$sformatf("total success are %0d",correct_count),UVM_MEDIUM);
			`uvm_info("report_phase",$sformatf("total erorrs are %0d",error_count),UVM_MEDIUM);
		endfunction: report_phase

	endclass : FIFO_scoreboard
endpackage : FIFO_scoreboard_pkg