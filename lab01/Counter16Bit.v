
/* 16 bit counter 
 *
 * INPUT  : digital signal
 * OUTPUT : num modulo 2^16 of detected signal posedges
 */
 
module Counter16Bit (input wire clk, output reg [15:0] value = 16'b0);

    always @(posedge clk) begin
        value <= value + 16'b1;
    end

endmodule