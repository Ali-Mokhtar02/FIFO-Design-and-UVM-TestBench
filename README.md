# FIFO-Verilog-Design-and-UVM-TestBench
The specs of the design can be found in the first page of the pdf file "Questa_Results.pdf".
In this Repo you will find a buggy FIFO design "FIFO_original_Buggy_design.v" and the bug free design "FIFO.sv". 
The objective is to verifiy the given buggy design and fix it if any bugs are found
A verification plan and top level UVM environment testbench were created to verify the design functionality.
The DUT outputs are compared to the outputs of the golden model in "scoreboard_FIFO_pkg.sv" and the DUT is guarded by assertions in the macro "enable_assertions".
Using this Testbench all the bugs found were reported in the Bug report in the documentation file and fixed in "FIFO.sv" file with comments stating the bugs causes in "FIFO_original_Buggy_design.v"
Note:
The line "+define+enable_assertions -work work FIFO.sv +cover -covercells" in "compile.txt" allows the simulator to include this macro in the compilation of the file.
