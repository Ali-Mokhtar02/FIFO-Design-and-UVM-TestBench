package FIFO_test_pkg;
	import uvm_pkg::*;
	import FIFO_env_pkg::*;
	import FIFO_config_pkg::*;
	import FIFO_reset_sequence_pkg::*;
	import FIFO_main_sequence_pkg::*;
	import FIFO_seq_item_pkg::*;
	
	
	`include "uvm_macros.svh"
	class FIFO_test extends uvm_test;
		`uvm_component_utils(FIFO_test);
		FIFO_env FIFO_test_env;
		FIFO_config_obj FIFO_test_cfg;
		FIFO_reset_sequence FIFO_test_rst_seq;
		FIFO_main_sequence FIFO_test_main_seq;

		function  new(string name="FIFO_test", uvm_component parent=null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			FIFO_test_cfg= FIFO_config_obj::type_id::create("FIFO_test_cfg",this);
			FIFO_test_env= FIFO_env::type_id::create("FIFO_test_env",this);
			FIFO_test_main_seq= FIFO_main_sequence::type_id::create("FIFO_test_main_seq",this);
			FIFO_test_rst_seq= FIFO_reset_sequence::type_id::create("FIFO_test_rst_seq",this);
			if(! uvm_config_db#(virtual FIFO_Interface)::get(this, "", "FIFO_IF",FIFO_test_cfg.FIFO_config_vif) )
				`uvm_fatal("build_phase", "get of FIFO interface failed in test");

			uvm_config_db#( uvm_active_passive_enum)::set(this, "*", "FIFO_agent_type",UVM_ACTIVE);
			uvm_config_db#( FIFO_config_obj)::set(this, "*", "FIFO_CFG",FIFO_test_cfg);
		endfunction : build_phase 

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			phase.raise_objection(this);
			`uvm_info("run_phase","Reset asserted", UVM_MEDIUM);
			FIFO_test_rst_seq.start(FIFO_test_env.FIFO_env_agent.FIFO_agent_sqr);
			`uvm_info("run_phase", "Reset deasserted", UVM_MEDIUM);
			`uvm_info("run_phase", "Stimulus generation starts", UVM_MEDIUM);
			FIFO_test_main_seq.start(FIFO_test_env.FIFO_env_agent.FIFO_agent_sqr);
			`uvm_info("run_phase", "Stimulus generation ends", UVM_MEDIUM);
			phase.drop_objection(this);
		endtask : run_phase
	endclass : FIFO_test
endpackage : FIFO_test_pkg