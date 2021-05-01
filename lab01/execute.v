
module Esecutor (

    /* cmds flags */
    input wire [ 5:0] cmdFlags;
    /* executable cmd args */
    input wire [31:0] cmdArgs [1:0];

    /* ready to execute next cmd flag */
    output reg        readNextCmdFlag;
    /* need to change addr flag */
    output reg        addrChangeFlag;
    /* new execution addr offset */
    output reg [31:0] newAddrOff;

);

    /* cmp equal flag */
    reg EQ_FLAG_;
    /* cmp greater flag */
    reg GG_FLAG_;

    /* registers */
    reg [31:0] REGS_ [31:0];

    /* execution modules stuff */

endmodule