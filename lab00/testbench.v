`include "ClockDomainCrossing.v"
`timescale 1ns / 10ps

module testbench ();

/* just some test environment */
	reg clkA = 1'b0;
	reg clkB = 1'b0;
	reg send = 1'b0;

	reg [15:0] data = 16'b0;

	wire ready;
	wire [15:0] out;

	always @(posedge ready) begin
		#2

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

/* testable module */
	CDCHandler #(.DATA_SIZE_(16)) handler  (.clkA   (clkA)	  , .clkB (clkB) ,
											.inData (data)	  , .send (send) ,
											.ready  (ready)   , .out  (out)   );
/* test settings */
	initial begin

		$dumpvars;
		$display ("Testing ClockDomainCrossing.v...");
		#200 $finish;

	end

endmodule