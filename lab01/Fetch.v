
`include "Memory.v"

/* getting new cmd & args from memory */
module Fetcher  #(

    /* words size in bits */
    parameter WORD_SIZE_            = 32    ,
    /* addr size */
    parameter ADDR_SIZE_            = 32    ,
    /* num or words in this memory block */
    parameter WORDS_NUM_            = 64    ,
    /* code segment init file name */
    parameter IN_NAME_              = "CODE.txt"

)
(
    /* clk */
    input wire CLK_                              ,
    /* to know when executor need next cmd */
    input wire READY_FL_                 ,

    /* to know next cmd addr */
    input wire [01 : 00] PREV_CMD_SIZE_               ,
    /* to know if fetcher should change execution addr */
    input wire JMP_FL_                  ,
    /* new execution addr offset */
    input wire [ADDR_SIZE_ - 1 : 00] NEW_EXEC_ADDR_OFFSET_   ,

    /* cmd info for executor & decoder */
    output wire [WORD_SIZE_ * 3 - 1 : 00] CMD_ARGS_,

    /* execute flag */
    output reg EXEC_FL_

);

    /* instruction pointer */
    reg [ADDR_SIZE_ - 1:0] IP;

    initial begin

        IP = 0;
        EXEC_FL_ = 0;

    end

    /* code segment reading stuff */
    CodeSegment #(.WORD_SIZE_ (WORD_SIZE_), .ADDR_SIZE_ (ADDR_SIZE_),
                  .WORDS_NUM_ (WORDS_NUM_), .IN_NAME_ (IN_NAME_))

                CS (.addr (IP), .value (CMD_ARGS_));

    always @(posedge CLK_) begin

        if (~READY_FL_ && ~EXEC_FL_)
            EXEC_FL_ <= 1;
        if (READY_FL_)
            EXEC_FL_ <= 0;

    end

    always @(posedge CLK_) begin
    if (READY_FL_) begin

        if (JMP_FL_)
            IP <= IP + NEW_EXEC_ADDR_OFFSET_;

        else
            IP <= IP + PREV_CMD_SIZE_;

    end
    end

endmodule