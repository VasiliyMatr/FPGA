
`include "Fetch.v"
`include "Decode.v"
`include "Execute.v"

`timescale 1ns / 10ps

module testbench ();

/* just some test environment */
    reg clk = 1'b1;

    always begin
        #1 clk = ~clk;
    end

    wire [1:0] cmdSize;
    wire readyFl;
    wire jmpFl;

    wire [31 : 00] newExecAddrOff;
    wire [95 : 00] cmdArgs;

    /* !!! MY THANKS TO INTEL FOR LITTLE ENDIAN (NICE XXX 3) !!! */
        wire [95 : 00] cmdArgsRev;

        genvar i;
        generate
            for (i = 0; i < 3; i = i + 1) begin

                assign cmdArgsRev [07 + i * 32 : 00 + i * 32] = cmdArgs [31 + i * 32 : 24 + i * 32];
                assign cmdArgsRev [15 + i * 32 : 08 + i * 32] = cmdArgs [23 + i * 32 : 16 + i * 32];
                assign cmdArgsRev [23 + i * 32 : 16 + i * 32] = cmdArgs [15 + i * 32 : 08 + i * 32];
                assign cmdArgsRev [31 + i * 32 : 24 + i * 32] = cmdArgs [07 + i * 32 : 00 + i * 32];

            end
        endgenerate


    wire [05 : 00] cmdFlgs;

    wire [127 : 00] dump;

    wire execFl;

/* testable modules */
    Executor executor (.CLK_ (clk), .EXEC_FL_ (execFl), .CMD_FLGS_ (cmdFlgs),
                       .CMD_ARG_ (cmdArgsRev), .READY_FL_ (readyFl),
                       .JMP_FL_ (jmpFl), .NEW_EXEC_ADDR_OFF_ (newExecAddrOff),
                       .DUMP_ (dump));

    Fetcher fetcher (.CLK_ (clk), .PREV_CMD_SIZE_ (cmdSize),
                     .READY_FL_ (readyFl), .JMP_FL_ (jmpFl),
                     .NEW_EXEC_ADDR_OFFSET_ (newExecAddrOff),
                     .CMD_ARGS_ (cmdArgs), .EXEC_FL_ (execFl));

    Decoder decoder (.CMD_CODE_ (cmdArgsRev [07 : 00]), .CMD_SIZE_ (cmdSize),
                     .CMD_FLGS_ (cmdFlgs));

/* test settings */
    initial begin

        $dumpvars;
        $display ("Testing cpu...");
        #2000 $finish;

    end

endmodule