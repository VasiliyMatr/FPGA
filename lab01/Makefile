
iver_test: perfom_test cleanup

perfom_test:

	iverilog Testbench.v -o Test
	vvp Test
	gtkwave dump.vcd

cleanup: perfom_test
	rm Test
	rm dump.vcd