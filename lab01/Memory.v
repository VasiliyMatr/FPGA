
/* for code segment memory - reads 3 words (cmd & args) from addr */
module CodeSegment (

    /* addr to read from */
    input  wire [32 - 1:0] addr     ,

    /* readen addr data */
    output wire [32 * 3 - 1:0] value

);

    /* rom block */
    reg [32 - 1:0] MEM [58 - 1:0];

    /* code read from file */
    initial begin
        $readmemh ("CODE.txt", MEM);
    end

    /* data read from code segment */
    assign value = MEM [addr + 0] + (MEM [addr + 1] << 32) + (MEM [addr + 2] << (32 * 2));

endmodule