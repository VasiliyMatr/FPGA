
module Decoder (

    /* cmd to decode */
    input wire  [7:0] CMD_CODE_         ,

    /* size of decoded cmd */
    output reg  [1:0] CMD_SIZE_ = 0   ,
    /* only one flag should be 1 - executable cmd flag */
    output reg  [5:0] CMD_FLGS_ = 0

);

    /* cmd decode */
    always @(*) begin
        case (CMD_CODE_)

            77: CMD_FLGS_ = 6'b100000;
            65: CMD_FLGS_ = 6'b010000;
            67: CMD_FLGS_ = 6'b001000;

            74: CMD_FLGS_ = 6'b000100;
            69: CMD_FLGS_ = 6'b000010;
            71: CMD_FLGS_ = 6'b000001;

        endcase
    end

    /* cmd size decode */
    always @(*) begin
        case (CMD_CODE_)

            77: CMD_SIZE_ = 2'b11;
            65: CMD_SIZE_ = 2'b01;
            67: CMD_SIZE_ = 2'b01;

            74: CMD_SIZE_ = 2'b10;
            69: CMD_SIZE_ = 2'b10;
            71: CMD_SIZE_ = 2'b10;

        endcase
    end

endmodule