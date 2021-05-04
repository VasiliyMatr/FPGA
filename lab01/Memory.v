
/* for code segment memory - reads 3 words (cmd & args) from addr */
module CodeSegment #(

    /* words size in bits */
    parameter WORD_SIZE_            = 32    ,
    /* addr size */
    parameter ADDR_SIZE_            = 32    ,
    /* num or words in this memory block */
    parameter WORDS_NUM_            = 64  ,
    /* mem init file name */
    parameter IN_NAME_              = "CODE.txt"

)
(

    /* addr to read from */
    input  wire [ADDR_SIZE_ - 1:0] addr     ,

    /* readen addr data */
    output wire [WORD_SIZE_ * 3 - 1:0] value

);

    /* rom block */
    reg [WORD_SIZE_ - 1:0] MEM [WORDS_NUM_ - 1:0];

    /* code read from file */
    initial begin
        $readmemh ("CODE.txt", MEM);
    end

    /* data read from code segment */
    assign value = MEM [addr + 0] + (MEM [addr + 1] << WORD_SIZE_) + (MEM [addr + 2] << (WORD_SIZE_ * 2));

endmodule