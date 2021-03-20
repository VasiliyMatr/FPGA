`include "ClockDomainCrossing.v"
`timescale 1ns / 10ps

module testbench ();

	reg clkA = 1'b0;
	reg clkB = 1'b0;
	reg send = 1'b0;

	reg [15:0] data = 16'b0;

	wire aReady;
	wire [15:0] out = 16'b0;

	always @(posedge aReady) begin
		if (data === 16'hABBA)
			data = 16'hACDC;
		else
			data = 16'hABBA;
	end

	always begin
		#1 clkA = ~clkA;
	end

	always begin
		#1	send = 0;
		#20 send = 1;
	end

	always begin
		#1.1442 clkB = ~clkB;
	end

/* outs */
    // wire [3:0] dEn;
    // wire [6:0] dDi;

/* testable module */
	CDCHandler handler (.CLKa    (clkA)	  , .CLKb  (clkB),
						.aDataIn (data)	  , .aSend (send),
						.aReady  (aReady) , .bOut  (out));
	// top test(.CLK (clk), .DS_EN1 (dEn[0]), .DS_EN2 (dEn[1]), .DS_EN3 (dEn[2]), .DS_EN4 (dEn[3]), 
    //          .DS_A (dDi[0]), .DS_B (dDi[1]), .DS_C (dDi[2]), .DS_D (dDi[3]), .DS_E (dDi[4]), .DS_F (dDi[5]), .DS_G (dDi[6]));

/* test settings */
	initial begin

		$dumpvars;
		$display ("Testing ClockDomainCrossing.v...");
		#20000 $finish;

	end

endmodule




