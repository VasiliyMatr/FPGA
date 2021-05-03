
`include "fetch.v"
`include "decode.v"
`include "execute.v"

`timescale 1ns / 10ps

module testbench ();

/* just some test environment */
    reg clk = 1'b1;

    always begin
        #1 clk = ~clk;
    end

    wire [1:0] prevCmdSize;
    wire readNextCmdFlag;
    wire addrChangeFlag;

    wire [31 : 00] newAddrOff;
    wire [95 : 00] cmdInfo;

    wire [05 : 00] cmdFlags;

    wire exec;

/* testable modules */


    Executor executor (.EXEC_FL_ (exec), .CMD_FL_ (cmdFlags), .CMD_ARG_ (cmdInfo),
                       .READY_FL_ (readNextCmdFlag), .JMP_FL_ (addrChangeFlag),
                       .NEW_EXEC_ADDR_OFF_ (newAddrOff));

    Fetcher fetcher (.clk (clk), .prevCmdSize (prevCmdSize), .readNextCmdFlag (readNextCmdFlag),
                     .addrChangeFlag (addrChangeFlag), .newAddrOff (newAddrOff),
                     .cmdInfo (cmdInfo), .exec (exec));

    Decoder decoder (.cmdId (cmdInfo [07 : 00]), .cmdSize (prevCmdSize),
                     .cmdsFlags (cmdFlags));

/* test settings */
    initial begin

        $dumpvars;
        $display ("Testing ClockDomainCrossing.v...");
        #200 $finish;

    end

endmodule