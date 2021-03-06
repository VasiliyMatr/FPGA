`include "SRLatch.v"

module DLatch_m(

	input  wire D		,
	input  wire E		,

	output wire OUT		,
	output wire XOUT

);

	wire srLatchS;
	wire srLatchR;


	assign srLatchS = D && E;
	assign srLatchR =~D && E;

	SRLatch_m SRLatch (.R (srLatchR), .S (srLatchS), .OUT (OUT), .XOUT(XOUT));	

endmodule