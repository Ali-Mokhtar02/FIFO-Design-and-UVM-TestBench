package FIFO_env_pkg;
	import uvm_pkg::*;
	import FIFO_agent_pkg::*;
	import FIFO_scoreboard_pkg::*;
	import FIFO_coverage_pkg::*;
	`include "uvm_macros.svh"
	class FIFO_env extends uvm_env;
		`uvm_component_utils(FIFO_env);
		FIFO_agent FIFO_env_agent;
		FIFO_scoreboard FIFO_env_sb;
		FIFO_coverage FIFO_env_coverage;
		function new(string name="FIFO_env", uvm_component parent = null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			FIFO_env_agent=FIFO_agent::type_id::create("FIFO_env_agent",this);
			FIFO_env_sb= FIFO_scoreboard::type_id::create("FIFO_env_sb",this);
			FIFO_env_coverage=FIFO_coverage::type_id::create("FIFO_env_coverage",this);
		endfunction : build_phase 

		function void connect_phase(uvm_phase phase);
			FIFO_env_agent.agent_ap.connect(FIFO_env_sb.sb_exp);
			FIFO_env_agent.agent_ap.connect(FIFO_env_coverage.coverage_exp);
		endfunction : connect_phase 

	endclass : FIFO_env
endpackage : FIFO_env_pkg