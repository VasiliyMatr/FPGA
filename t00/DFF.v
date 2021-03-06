`include "DLatch.v"

module DFlipFlop_m(

	input  wire E		,
	input  wire D		,

	output wire OUT		,
	output wire XOUT

);
	
	wire masterE;
	wire masterOut;

	assign masterE = ~E;


	DLatch_m Master (.E (masterE), .D (D        ), .OUT (masterOut));
	DLatch_m Slave  (.E (E      ), .D (masterOut), .OUT (OUT), .XOUT(XOUT));

endmodule