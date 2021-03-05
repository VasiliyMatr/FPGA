`include "DisplayMaster.v"
`include "Counter.v"
`include "FreqDivider.v"

`define LESS_COUNT_DISPLAYABLE_BIT 15

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

/* sys ticks counter */
    `COUNTER (CLK, 40, counterVal)

/* clk for display */
    wire         dispClk  = counterVal [12];

/* digits to show */
    wire [6:0]   digit1, digit2, digit3, digit4;

/* displays masters */
    DisplayMaster   masterOf1Digit  (.number (counterVal [3  + `LESS_COUNT_DISPLAYABLE_BIT :      `LESS_COUNT_DISPLAYABLE_BIT])  , .displayMask (digit1));
    DisplayMaster   masterOf2Digit  (.number (counterVal [7  + `LESS_COUNT_DISPLAYABLE_BIT : 4  + `LESS_COUNT_DISPLAYABLE_BIT])  , .displayMask (digit2));
    DisplayMaster   masterOf3Digit  (.number (counterVal [11 + `LESS_COUNT_DISPLAYABLE_BIT : 8  + `LESS_COUNT_DISPLAYABLE_BIT])  , .displayMask (digit3));
    DisplayMaster   masterOf4Digit  (.number (counterVal [15 + `LESS_COUNT_DISPLAYABLE_BIT : 12 + `LESS_COUNT_DISPLAYABLE_BIT])  , .displayMask (digit4));

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