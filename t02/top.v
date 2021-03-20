`include "DisplayMaster.v"
`include "Counter.v"

/* counterVal bit is used to clock memory stuff;
 * this define is used to choose bit number
 */
 
`define MEM_CLK_BIT_ 24

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
    `COUNTER (CLK, 32, counterVal)

/* grey number buff */
    wire [15:0]  greyNum;

/* ROM with grey numbers */
    rom          greyData        (.clock   (counterVal [`MEM_CLK_BIT_]),
                                  .address (counterVal [`MEM_CLK_BIT_ + 4 : `MEM_CLK_BIT_ + 1]),
                                  .q       (greyNum));

/* clk for display */
    wire         dispClk  = counterVal [12];

/* digits to show */
    wire [6:0]   digit1, digit2, digit3, digit4;

/* displays masters */
    DisplayMaster   masterOf1Digit  (.number (greyNum [03 : 00])  , .displayMask (digit1));
    DisplayMaster   masterOf2Digit  (.number (greyNum [07 : 04])  , .displayMask (digit2));
    DisplayMaster   masterOf3Digit  (.number (greyNum [11 : 08])  , .displayMask (digit3));
    DisplayMaster   masterOf4Digit  (.number (greyNum [15 : 12])  , .displayMask (digit4));

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