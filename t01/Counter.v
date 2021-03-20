
/* Counter macro 
 *
 * INPUT  : digital signal; num of bits in counter; name for register with counter value
 * OUTPUT : num modulo 2^numOfBits of detected signal posedges
 */

`define COUNTER( clk, numOfBits, regName )      \
reg [numOfBits - 1 : 0] regName = numOfBits'b0; \
                                                \
always @(posedge clk) begin                     \
    regName <= regName  + numOfBits'b1;         \
end