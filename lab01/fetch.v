
`include "memory.v"

/* getting new cmd & args from memory */
module Fetcher  #(

    /* words size in bits */
    parameter WORD_SIZE_            = 32    ,
    /* addr size */
    parameter ADDR_SIZE_            = 32    ,
    /* num or words in this memory block */
    parameter WORDS_NUM_            = 1024  ,
    /* code segment init file name */
    parameter IN_NAME_              = "CODE.txt"

)
(
    /* clk */
    input wire clk                              ,
    /* to know when executor need next cmd */
    input wire readyFL                 ,

    /* to know next cmd addr */
    input wire [1:0] prevCmdSize               ,
    /* to know if fetcher should change execution addr */
    input wire addrChangeFlag                  ,
    /* new execution addr offset */
    input wire [ADDR_SIZE_ - 1:0] newAddrOff   ,

    /* cmd info for executor & decoder */
    output wire [(WORD_SIZE_ * 3) - 1:0] cmdInfo,

    /* execute flag */
    output reg exec

);

    /* instruction pointer */
    reg [ADDR_SIZE_ - 1:0] RIP;

    initial begin

        RIP = 0;
        exec = 0;

    end

    /* code segment reading stuff */
    CodeSegment #(.WORD_SIZE_ (WORD_SIZE_), .ADDR_SIZE_ (ADDR_SIZE_),
                  .WORDS_NUM_ (WORDS_NUM_), .IN_NAME_ (IN_NAME_))

                CS (.addr (RIP), .value (cmdInfo));

    always @(posedge clk) begin
        if (~readyFL && ~exec)
            exec <= 1;
        if (readyFL)
            exec <= 0;
    end

    always @(posedge clk) begin
    if (readyFL) begin

        if (addrChangeFlag)
            RIP <= RIP + newAddrOff;

        else
            RIP <= RIP + prevCmdSize;

    end
    end

endmodule