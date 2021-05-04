
module top(
    input  wire CLK,

/* displays on/off pins */
	output reg DS_EN1, DS_EN2, DS_EN3, DS_EN4,
/* displays diods on/off pins */
    output reg DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G
);

    wire [1:0] cmdSize;
    wire readyFl;
    wire jmpFl;

    wire [31 : 00] newExecAddrOff;
    wire [95 : 00] cmdArgs;
    wire [95 : 00] cmdArgsRev;

    genvar wordId;

    generate for (wordId = 0; wordId < 3; wordId = wordId + 1) begin : reverseGen

        assign cmdArgsRev [07 + wordId * 32 : 00 + wordId * 32] = cmdArgs [31 + wordId * 32 : 24 + wordId * 32];
        assign cmdArgsRev [15 + wordId * 32 : 08 + wordId * 32] = cmdArgs [23 + wordId * 32 : 16 + wordId * 32];
        assign cmdArgsRev [23 + wordId * 32 : 16 + wordId * 32] = cmdArgs [15 + wordId * 32 : 08 + wordId * 32];
        assign cmdArgsRev [31 + wordId * 32 : 24 + wordId * 32] = cmdArgs [07 + wordId * 32 : 00 + wordId * 32];

    end endgenerate

    wire [05 : 00] cmdFlgs;

    wire execFl;

    wire [127 : 00] dump;

/* testable modules */

    Executor executor (.CLK_ (CLK), .EXEC_FL_ (execFl), .CMD_FLGS_ (cmdFlgs),
                       .CMD_ARG_ (cmdArgsRev), .READY_FL_ (readyFl),
                       .JMP_FL_ (jmpFl), .NEW_EXEC_ADDR_OFF_ (newExecAddrOff),
                       .DUMP_ (dump));

    Fetcher fetcher (.CLK_ (CLK), .PREV_CMD_SIZE_ (cmdSize), .READY_FL_ (readyFl),
                     .JMP_FL_ (jmpFl), .NEW_EXEC_ADDR_OFFSET_ (newExecAddrOff),
                     .CMD_ARGS_ (cmdArgs), .EXEC_FL_ (execFl));

    Decoder decoder (.CMD_CODE_ (cmdArgsRev [07 : 00]), .CMD_SIZE_ (cmdSize),
                     .CMD_FLGS_ (cmdFlgs));

/* sys ticks counter */
	reg [13 - 1 : 0] counterVal = 13'b0;

	always @(posedge CLK) begin
		 counterVal <= counterVal + 13'b1;
	end

/* clk for display */
    wire         dispClk  = counterVal [12];

/* digits to show */
    wire [6:0]   digit1, digit2, digit3, digit4;

/* displays masters */
    DisplayMaster   masterOf1Digit  (.number (dump [07  : 00])  , .displayMask (digit1));
    DisplayMaster   masterOf2Digit  (.number (dump [39  : 32])  , .displayMask (digit2));
    DisplayMaster   masterOf3Digit  (.number (dump [71  : 64])  , .displayMask (digit3));
    DisplayMaster   masterOf4Digit  (.number (dump [103 : 96])  , .displayMask (digit4));

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