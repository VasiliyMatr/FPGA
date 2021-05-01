
/* getting new cmd & args from memory */
module Fetcher (
    /* to know next cmd addr */
    input wire [ 1:0] prevCmdSize     ,
    /* to know when executor need next cmd */
    input wire        readNextCmdFlag ,
    /* to know if fetcher should change execution addr */
    input wire        addrChangeFlag  ,
    /* new execution addr offset */
    input wire [31:0] newAddrOff      ,

    /* cmd info for executor & decoder */
    output reg [31:0] cmdInfo [2:0]     ,
);

    /* instruction pointer */
    reg [31:0] RIP = 32'b0;

/* memory reading stuff */
    

endmodule