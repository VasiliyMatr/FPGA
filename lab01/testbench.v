
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
    wire [95 : 00] cmdInfoReversed;

    genvar i;

    generate
        for (i = 0; i < 3; i = i + 1) begin

            assign cmdInfoReversed [07 + i * 32 : 00 + i * 32] = cmdInfo [31 + i * 32 : 24 + i * 32];
            assign cmdInfoReversed [15 + i * 32 : 08 + i * 32] = cmdInfo [23 + i * 32 : 16 + i * 32];
            assign cmdInfoReversed [23 + i * 32 : 16 + i * 32] = cmdInfo [15 + i * 32 : 08 + i * 32];
            assign cmdInfoReversed [31 + i * 32 : 24 + i * 32] = cmdInfo [07 + i * 32 : 00 + i * 32];

        end
    endgenerate


    wire [05 : 00] cmdFlags;

    wire exec;

    wire [127 : 00] DUMP_;

/* testable modules */


    Executor executor (.CLK_ (clk), .EXEC_FL_ (exec), .CMD_FL_ (cmdFlags),
                       .CMD_ARG_ (cmdInfoReversed), .READY_FL_ (readNextCmdFlag),
                       .JMP_FL_ (addrChangeFlag), .NEW_EXEC_ADDR_OFF_ (newAddrOff), .DUMP_ (DUMP_));

    Fetcher fetcher (.clk (clk), .prevCmdSize (prevCmdSize), .readyFL (readNextCmdFlag),
                     .addrChangeFlag (addrChangeFlag), .newAddrOff (newAddrOff),
                     .cmdInfo (cmdInfo), .exec (exec));

    Decoder decoder (.cmdId (cmdInfoReversed [07 : 00]), .cmdSize (prevCmdSize),
                     .cmdsFlags (cmdFlags));

/* test settings */
    initial begin

        $dumpvars;
        $display ("Testing ClockDomainCrossing.v...");
        #2000 $finish;

    end

endmodule