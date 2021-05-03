`include "execute.v"
`timescale 1ns / 10ps

module testbench ();

/* just some test environment */
    reg clk = 1'b0;

    reg [05 : 00] cmdFlags = 6'b001000;
    reg [95 : 00] cmdArgs = 96'b000000000000100000000100;

    wire readyFl;
    wire jmpFL;

    wire [31 : 00] newAddrOff;

    always begin
        #1 clk = ~clk;
    end

/* testable module */
    Executor executor (.CLK_ (clk), .CMD_FL_ (cmdFlags), .CMD_ARG_ (cmdArgs),
                       .READY_FL_ (readyFl), .JMP_FL_ (jmpFL),
                       .NEW_EXEC_ADDR_OFF_ (newAddrOff));

/* test settings */
    initial begin

        $dumpvars;
        $display ("Testing ClockDomainCrossing.v...");
        #200 $finish;

    end

endmodule