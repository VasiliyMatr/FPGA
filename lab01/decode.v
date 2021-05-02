
/* cmds codes */
`define MOV_CODE_ 77
`define ADD_CODE_ 65
`define CMP_CODE_ 67

`define JMP_CODE_ 74
`define JEQ_CODE_ 69
`define JGG_CODE_ 71

module Decoder (

    /* cmd to decode */
    input wire  [7:0] cmdId     ,

    /* size of decoded cmd */
    output reg  [1:0] cmdSize   ,
    /* only one flag should be 1 - executable cmd flag */
    output reg  [5:0] cmdsFlags

);

    /* cmd decode */
    always @(*) begin
        case (cmdId)

            `MOV_CODE_: cmdsFlags = 6'b100000;
            `ADD_CODE_: cmdsFlags = 6'b010000;
            `CMP_CODE_: cmdsFlags = 6'b001000;

            `JMP_CODE_: cmdsFlags = 6'b000100;
            `JEQ_CODE_: cmdsFlags = 6'b000010;
            `JGG_CODE_: cmdsFlags = 6'b000001;

        endcase
    end

    /* cmd size decode */
    always @(*) begin
        case (cmdId)

            `MOV_CODE_: cmdSize = 2'b11;
            `ADD_CODE_: cmdSize = 2'b01;
            `CMP_CODE_: cmdSize = 2'b01;

            `JMP_CODE_: cmdSize = 2'b10;
            `JEQ_CODE_: cmdSize = 2'b10;
            `JGG_CODE_: cmdSize = 2'b10;

        endcase
    end

endmodule