
`define _CMD_MOV_CODE 77
`define _CMD_ADD_CODE 65
`define _CMD_CMP_CODE 67

`define _CMD_JMP_CODE 74
`define _CMD_JEQ_CODE 69
`define _CMD_JGG_CODE 71

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

            `_CMD_MOV_CODE: CMD_FLGS_ = 6'b100000;
            `_CMD_ADD_CODE: CMD_FLGS_ = 6'b010000;
            `_CMD_CMP_CODE: CMD_FLGS_ = 6'b001000;

            `_CMD_JMP_CODE: CMD_FLGS_ = 6'b000100;
            `_CMD_JEQ_CODE: CMD_FLGS_ = 6'b000010;
            `_CMD_JGG_CODE: CMD_FLGS_ = 6'b000001;

        endcase
    end

    /* cmd size decode */
    always @(*) begin
        case (CMD_CODE_)

            `_CMD_MOV_CODE: CMD_SIZE_ = 2'b11;
            `_CMD_ADD_CODE: CMD_SIZE_ = 2'b01;
            `_CMD_CMP_CODE: CMD_SIZE_ = 2'b01;

            `_CMD_JMP_CODE: CMD_SIZE_ = 2'b10;
            `_CMD_JEQ_CODE: CMD_SIZE_ = 2'b10;
            `_CMD_JGG_CODE: CMD_SIZE_ = 2'b10;

        endcase
    end

endmodule