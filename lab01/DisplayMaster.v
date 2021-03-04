
/* Transforms hex digital into 7-bit display diods mask 
 *
 * INPUT  : hex number - [0, 15]
 * OUTPUT : display diods mask
 */

//        A
//   ===========
//   =         =
// F =         = B
//   =    G    =
//   ===========
//   =         =
// E =         = C
//   =         =
//   ===========
//        D

module DisplayMaster (input wire[3:0] number, output reg[6:0] displayMask = 7'b0);

    always @(*) begin
        case (number)

            00: displayMask <= 7'b1111110;
            01: displayMask <= 7'b0110000;
            02: displayMask <= 7'b1101101;
            03: displayMask <= 7'b1111001;
            04: displayMask <= 7'b0110011;
            05: displayMask <= 7'b1011011;
            06: displayMask <= 7'b1011111;
            07: displayMask <= 7'b1110000;
            08: displayMask <= 7'b1111111;
            09: displayMask <= 7'b1110011;
            10: displayMask <= 7'b1110111;
            11: displayMask <= 7'b0011111;
            12: displayMask <= 7'b1001110;
            13: displayMask <= 7'b0111101;
            14: displayMask <= 7'b1001111;
            15: displayMask <= 7'b1000111;

            default:;

        endcase
    end
    
endmodule