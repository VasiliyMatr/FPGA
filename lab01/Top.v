
`include "Execute.v"
`include "Fetch.v"
`include "Decode.v"
`include "DisplayMaster.v"
`include "Counter.v"

/* just main module
 *
 */

module top(
    input  wire CLK,

/* displays on/off pins */
	output reg DS_EN1, DS_EN2, DS_EN3, DS_EN4,
/* displays diods on/off pins */
    output reg DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G
);

    wire [1:0] prevCmdSize;
    wire readNextCmdFlag;
    wire addrChangeFlag;

    wire [31 : 00] newAddrOff;
    wire [95 : 00] cmdInfo;
    wire [95 : 00] cmdInfoReversed;

    genvar i;

    generate
        for (i = 0; i < 3; i = i + 1) begin : reverseGen

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

    Executor executor (.CLK_ (CLK), .EXEC_FL_ (exec), .CMD_FL_ (cmdFlags),
                       .CMD_ARG_ (cmdInfoReversed), .READY_FL_ (readNextCmdFlag),
                       .JMP_FL_ (addrChangeFlag), .NEW_EXEC_ADDR_OFF_ (newAddrOff), .DUMP_ (DUMP_));

    Fetcher fetcher (.clk (CLK), .prevCmdSize (prevCmdSize), .readyFL (readNextCmdFlag),
                     .addrChangeFlag (addrChangeFlag), .newAddrOff (newAddrOff),
                     .cmdInfo (cmdInfo), .exec (exec));

    Decoder decoder (.cmdId (cmdInfoReversed [07 : 00]), .cmdSize (prevCmdSize),
                     .cmdsFlags (cmdFlags));

/* sys ticks counter */
    `COUNTER (CLK, 13, counterVal)

/* clk for display */
    wire         dispClk  = counterVal [12];

/* digits to show */
    wire [6:0]   digit1, digit2, digit3, digit4;

/* displays masters */
    DisplayMaster   masterOf1Digit  (.number (DUMP_ [07  : 00])  , .displayMask (digit1));
    DisplayMaster   masterOf2Digit  (.number (DUMP_ [39  : 32])  , .displayMask (digit2));
    DisplayMaster   masterOf3Digit  (.number (DUMP_ [71  : 64])  , .displayMask (digit3));
    DisplayMaster   masterOf4Digit  (.number (DUMP_ [103 : 96])  , .displayMask (digit4));

/* operating display id */
    reg  [1:0]   dispId = 0;

/* main cycles */

        always @(posedge dispClk) begin
            dispId <= dispId + 1;
        end

        always @(*) begin
            case (dispId)

                2'b00: {DS_EN1, DS_EN2, DS_EN3, DS_EN4}  = 4'b1101;
                2'b01: {DS_EN1, DS_EN2, DS_EN3, DS_EN4}  = 4'b1011;
                2'b10: {DS_EN1, DS_EN2, DS_EN3, DS_EN4}  = 4'b0111;
                2'b11: {DS_EN1, DS_EN2, DS_EN3, DS_EN4}  = 4'b1110;

            endcase
        end

        always @(*) begin
            case (dispId)

                2'b00: {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = digit2;
                2'b01: {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = digit3;
                2'b10: {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = digit4;
                2'b11: {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = digit1;
                
            endcase
        end

endmodule