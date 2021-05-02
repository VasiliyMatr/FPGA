`include "decode.v"
`timescale 1ns / 10ps

module testbench ();

/* just some test environment */
    reg clk = 1'b0;

    wire [7:0] cmdId = 65;
    wire [1:0] cmdSize;
    wire [5:0] cmdFlags;

    always begin
        #1 clk = ~clk;
    end

/* testable module */
    Decoder decoder (.cmdId (cmdId), .cmdSize (cmdSize), .cmdsFlags (cmdFlags));

/* test settings */
    initial begin

        $dumpvars;
        $display ("Testing ClockDomainCrossing.v...");
        #200 $finish;

    end

endmodule