`include "DisplayMaster.v"
`include "Counter16Bit.v"
`include "FreqDivider.v"

/* just main module
 *
 */

module top(
    input CLK,

/* displays on/off pins */
	output DS_EN1, DS_EN2, DS_EN3, DS_EN4,
/* displays diods on/off pins */
    output DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G
);

/* freq div coeffs */
    reg [31:0]  dispChangeFreqDivider   = 32'h8000; // 32'h8000;  - value for real device
    reg [31:0]  counterFreqDivider      = 32'h10000; // 32'h10000; - value for real device

/* div freq clk */
    wire        dispDivClk;
    wire        countDivClk;

/* output number */
    wire [15:0] counterValue;

/* digits to show */
    wire [6:0]   digit1;
    wire [6:0]   digit2;
    wire [6:0]   digit3;
    wire [6:0]   digit4;

/* freq dividers */
    FreqDivider     dispDivider     (.clk (CLK), .counterInitVal (dispChangeFreqDivider) , .divClk (dispDivClk));
    FreqDivider     cntDivider      (.clk (CLK), .counterInitVal (counterFreqDivider)    , .divClk (countDivClk));

/* counter for output value */
    Counter16Bit    counter         (.clk (countDivClk), .value (counterValue));

/* displays masters */
    DisplayMaster   masterOf1Digit  (.number (counterValue [3:0])    , .displayMask (digit1));
    DisplayMaster   masterOf2Digit  (.number (counterValue [7:4])    , .displayMask (digit2));
    DisplayMaster   masterOf3Digit  (.number (counterValue [11:8])   , .displayMask (digit3));
    DisplayMaster   masterOf4Digit  (.number (counterValue [15:12])  , .displayMask (digit4));

/* masks to on/off diods and displays */
    reg [6:0]   diodsMask   = 0;
    reg [3:0]   digitsMask  = 4'b1101;

/* main cycles */

        always @(posedge dispDivClk) begin

            case (digitsMask)

                4'b1110: digitsMask  <= 4'b1101;
                4'b1101: digitsMask  <= 4'b1011;
                4'b1011: digitsMask  <= 4'b0111;
                4'b0111: digitsMask  <= 4'b1110;

            endcase
        end

        always @(posedge dispDivClk) begin

            // #5 /* wait for digitsMask assignation */

            case (digitsMask)

                4'b1110: diodsMask <= digit2;
                4'b1101: diodsMask <= digit3;
                4'b1011: diodsMask <= digit4;
                4'b0111: diodsMask <= digit1;
                
            endcase

        end

/* end of main cycles */

/* outputs assignation */
    assign {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G}   = diodsMask;
    assign {DS_EN1, DS_EN2, DS_EN3, DS_EN4}             = digitsMask;

endmodule