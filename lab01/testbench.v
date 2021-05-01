`include "fetch.v"
`timescale 1ns / 10ps

module testbench ();

/* just some test environment */
    reg clk = 1'b0;

    wire [1:0] prevCmdSize = 2'b10;
    wire       addrChangeFlag = 1'b0;
    wire [31:0] newAddrOffset = 32'b00;

    wire [95:0] out;

    always begin
        #1 clk = ~clk;
    end

/* testable module */
    Fetcher fetcher (.prevCmdSize (prevCmdSize)     , .addrChangeFlag (addrChangeFlag),
                     .newAddrOff (newAddrOffset)    , .cmdInfo (out), .readNextCmdFlag (clk));

/* test settings */
    initial begin

        $dumpvars;
        $display ("Testing ClockDomainCrossing.v...");
        #200 $finish;

    end

endmodule