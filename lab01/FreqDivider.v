
/* Frequency divider
 *
 * INPUT  : signal with dividable freq; div coeff
 * OUTPUT : signal with divided   freq
 */

module FreqDivider (input wire clk, input wire[31:0] counterInitVal, output reg divClk = 0);
    
    reg [31:0]counter = 32'b0;

    always @(posedge clk) begin

        if (counter == 0) begin
        
            counter <= counterInitVal;
            divClk <= ~divClk;

        end else begin
        
            counter <= counter - 32'b1;
        
        end

    end

endmodule