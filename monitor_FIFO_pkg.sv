package FIFO_monitor_pkg;
	import uvm_pkg::*;
	import FIFO_seq_item_pkg::*;
	`include "uvm_macros.svh"
	class FIFO_monitor extends  uvm_monitor;
		`uvm_component_utils(FIFO_monitor);
		virtual FIFO_Interface FIFO_monitor_vif;
		uvm_analysis_port #(FIFO_seq_item) monitor_ap;
		FIFO_seq_item FIFO_monitor_seq_item;

		function  new(string name="FIFO_monitor", uvm_component parent=null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			monitor_ap= new("monitor_ap",this);
		endfunction: build_phase

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				FIFO_monitor_seq_item = FIFO_seq_item::type_id::create("FIFO_monitor_seq_item");

				@(negedge FIFO_monitor_vif.clk);
				FIFO_monitor_seq_item.data_in = FIFO_monitor_vif.data_in;
				FIFO_monitor_seq_item.rst_n = FIFO_monitor_vif.rst_n;
				FIFO_monitor_seq_item.wr_en = FIFO_monitor_vif.wr_en;
				FIFO_monitor_seq_item.rd_en = FIFO_monitor_vif.rd_en;
				FIFO_monitor_seq_item.full = FIFO_monitor_vif.full;
				FIFO_monitor_seq_item.empty = FIFO_monitor_vif.empty;
				FIFO_monitor_seq_item.almostfull = FIFO_monitor_vif.almostfull;
				
				FIFO_monitor_seq_item.almostempty = FIFO_monitor_vif.almostempty;
				FIFO_monitor_seq_item.overflow = FIFO_monitor_vif.overflow;
				FIFO_monitor_seq_item.underflow = FIFO_monitor_vif.underflow;
				FIFO_monitor_seq_item.wr_ack = FIFO_monitor_vif.wr_ack;
				FIFO_monitor_seq_item.data_out = FIFO_monitor_vif.data_out;

				monitor_ap.write(FIFO_monitor_seq_item);
				`uvm_info("run_phase",FIFO_monitor_seq_item.convert2string(),UVM_HIGH);
			end
		endtask : run_phase
	endclass : FIFO_monitor
endpackage : FIFO_monitor_pkg