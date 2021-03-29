
iver_test: perfom_test cleanup

perfom_test:

	iverilog testbench.v -o test
	vvp test
	gtkwave dump.vcd

cleanup: perfom_test
	rm test
	rm dump.vcd