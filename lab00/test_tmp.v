`include "top.v"
`timescale 1ns / 100ps

module testbench ();

	reg clk = 1'b0;

	always begin
		#1 clk = ~clk;
	end

/* outs */
    wire [3:0] dEn;
    wire [6:0] dDi;

/* testable module */
	top test(.CLK (clk), .DS_EN1 (dEn[0]), .DS_EN2 (dEn[1]), .DS_EN3 (dEn[2]), .DS_EN4 (dEn[3]), 
             .DS_A (dDi[0]), .DS_B (dDi[1]), .DS_C (dDi[2]), .DS_D (dDi[3]), .DS_E (dDi[4]), .DS_F (dDi[5]), .DS_G (dDi[6]));

/* test settings */
	initial begin

		$dumpvars;
		$display ("Testing top.v...");
		#20000000 $finish;

	end

endmodule