package FIFO_config_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	class FIFO_config_obj extends  uvm_object;

		`uvm_object_utils(FIFO_config_obj);

		virtual FIFO_Interface FIFO_config_vif;
		uvm_active_passive_enum active;

		function new(string name="FIFO_config_obj");
			super.new(name);
		endfunction : new
		
	endclass : FIFO_config_obj
endpackage : FIFO_config_pkg