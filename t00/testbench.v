`include "DFF.v"
`timescale 1ns / 10ps

module testbench ();

	reg clk = 1'b0;
	reg signal = 1'b1;

	always begin
		#1 clk = ~clk;
	end

	always begin
		#3.1415926535 signal = ~signal;
	end

	wire out;
	wire xout;

	DFlipFlop_m DFF(.D (signal), .E (clk), .OUT (out), .XOUT (xout));

	initial begin

		$dumpvars;
		$display ("Testing...");
		#200 $finish;

	end

endmodule




