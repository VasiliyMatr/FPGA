module SRLatch_m(

	input  wire R		,
	input  wire S		,

	output wire OUT		,
	output wire XOUT
	
);

	assign OUT  = ~R && (S || OUT);
	assign XOUT = ~S && (R || XOUT);

endmodule
