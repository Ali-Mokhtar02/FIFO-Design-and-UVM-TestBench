package FIFO_coverage_pkg;
	import uvm_pkg::*;
	import FIFO_seq_item_pkg::*;
	`include "uvm_macros.svh"
	class FIFO_coverage extends  uvm_component;
		`uvm_component_utils(FIFO_coverage);
		
		uvm_analysis_export #(FIFO_seq_item) coverage_exp;
		uvm_tlm_analysis_fifo #(FIFO_seq_item) coverage_fifo;
		FIFO_seq_item FIFO_coverage_seq_item;

		covergroup FIFO_cg();
			wr_encp: coverpoint FIFO_coverage_seq_item.wr_en;
			rd_encp: coverpoint FIFO_coverage_seq_item.rd_en;
			fullcp: coverpoint FIFO_coverage_seq_item.full;
			almostfullcp: coverpoint FIFO_coverage_seq_item.almostfull;
			almostemptycp: coverpoint FIFO_coverage_seq_item.almostempty;
			overflowcp: coverpoint FIFO_coverage_seq_item.overflow;
			underflowcp: coverpoint FIFO_coverage_seq_item.underflow;			
			wr_ackcp: coverpoint FIFO_coverage_seq_item.wr_ack;
			//CROSS COVERAGE groups:::
			almostfull_cross: cross wr_encp,rd_encp,almostfullcp
			{
				bins wr_rd_full= binsof(wr_encp) intersect {1} && binsof(rd_encp) && binsof(almostfullcp);

			}

			almostempty_cross: cross wr_encp,rd_encp,almostemptycp
			{
				bins wr_rd_full= binsof(wr_encp) intersect {1} && binsof(rd_encp) && binsof(almostemptycp);

			}

			full_cross: cross wr_encp,rd_encp,fullcp
			{
				bins wr_rd_full= binsof(wr_encp) intersect {1} && binsof(rd_encp) intersect {1} && binsof(fullcp);
				ignore_bins no_write= binsof(wr_encp) intersect {0}; //when write is low FIFO cant be full

			}

			overflow_cross: cross wr_encp,rd_encp,overflowcp
			{
				bins wr_rd_full= binsof(wr_encp) intersect {1} && binsof(rd_encp) intersect {1} && binsof(overflowcp);
				ignore_bins wr_not_high = binsof(wr_encp) intersect {0}; //when write is high no overflow will happen
			}

			underflow_cross: cross wr_encp,rd_encp,underflowcp
			{
				bins wr_rd_full= binsof(wr_encp) intersect {1} && binsof(rd_encp) intersect {1} && binsof(underflowcp);
				ignore_bins rd_not_high = binsof(rd_encp) intersect {0}; // when read is low no underflow will happen
			}

			wr_ack_cross: cross wr_encp,rd_encp,wr_ackcp
			{
				bins wr_rd_full= binsof(wr_encp) intersect {1} && binsof(rd_encp) intersect {1} && binsof(wr_ackcp);
				ignore_bins wr_not_high = binsof(wr_encp) intersect {0};
			}

		endgroup

		function new(string name="FIFO_coverage", uvm_component parent=null );
			super.new(name,parent);
			FIFO_cg=new();
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			coverage_exp= new("coverage_exp",this);
			coverage_fifo= new("coverage_fifo",this);
		endfunction: build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			coverage_exp.connect(coverage_fifo.analysis_export);

		endfunction: connect_phase

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				coverage_fifo.get(FIFO_coverage_seq_item);
				if(FIFO_coverage_seq_item.rst_n)
					FIFO_cg.sample();
			end
		endtask : run_phase

	endclass : FIFO_coverage
endpackage : FIFO_coverage_pkg