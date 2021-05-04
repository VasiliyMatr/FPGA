
/* getting new cmd & args from memory */
module Fetcher  (

    /* clk */
    input wire CLK_                              ,
    /* to know when executor need next cmd */
    input wire READY_FL_                 ,

    /* to know next cmd addr */
    input wire [01 : 00] PREV_CMD_SIZE_               ,
    /* to know if fetcher should change execution addr */
    input wire JMP_FL_                  ,
    /* new execution addr offset */
    input wire [32 - 1 : 00] NEW_EXEC_ADDR_OFFSET_   ,

    /* cmd info for executor & decoder */
    output wire [32 * 3 - 1 : 00] CMD_ARGS_,

    /* execute flag */
    output reg EXEC_FL_

);

    /* instruction pointer */
    reg [32 - 1:0] IP;

    initial begin

        IP = 0;
        EXEC_FL_ = 0;

    end

    /* code segment reading stuff */
    CodeSegment CS (.addr (IP), .value (CMD_ARGS_));

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