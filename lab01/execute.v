
`include "memory.v"

module Esecutor   #(

    /* words size in bits */
    parameter WORD_SIZE_            = 32    ,
    /* addr size */
    parameter ADDR_SIZE_            = 32    ,
    /* num or words in RAM memory block */
    parameter WORDS_NUM_            = 4096

)
(

    /* cmds flags */
    input wire [5:0] cmdFlags;
    /* executable cmd args */
    input wire [WORD_SIZE_ * 3 - 1:0] cmdArgs;

    /* ready to execute next cmd flag */
    output reg        readNextCmdFlag;
    /* need to change addr flag */
    output reg        addrChangeFlag;
    /* new execution addr offset */
    output reg [ADDR_SIZE_ - 1:0] newAddrOff;

);

    /* cmd flags wires */
    wire MOV_CFL_ = cmdFlags [0];
    wire ADD_CFL_ = cmdFlags [1];
    wire CMP_CFL_ = cmdFlags [2];

    wire JMP_CFL_ = cmdFlags [3];
    wire JEQ_CFL_ = cmdFlags [4];
    wire JGG_CFL_ = cmdFlags [5];

    /* cmp equal flag */
    reg CMP_EQ_FL_;
    /* cmp greater flag */
    reg CMP_GG_FL_;

    /* registers */
    reg [WORD_SIZE_ - 1:0] REGS_ [31:0];

    reg [WORD_SIZE_ - 1:0] MEM_ [WORDS_NUM_ - 1:0];

    /* write flags */
    reg regWriteFl = 0;
    reg memWriteFl = 0;

    /* write buffs */
    reg [WORD_SIZE_ - 1:0] reg2Write = 0;
    reg [WORD_SIZE_ - 1:0] mem2Wirte = 0;

    /* write addrs */
    reg [4:0] regId2Write = 0;
    reg [ADDR_SIZE_ - 1:0] memId2Write = 0;

    /* JUMPS STUFF */
        always @(posedge JMP_CFL_ or posedge JEQ_CFL_ or posedge JGG_CFL_) begin

            if (JMP_CFL_ || (JEQ_CFL_ && CMP_EQ_FL_) || (JGG_CFL_ && CMP_GG_FL_)) begin
                newAddrOff <= cmdArgs [WORD_SIZE_ * 3 - 9 : WORD_SIZE_ * 2];
            end

        end

        always @(posedge cmdFlags) begin

            if (JMP_CFL_ || (JEQ_CFL_ && CMP_EQ_FL_) || (JGG_CFL_ && CMP_GG_FL_)) begin
                addrChangeFlag <= 1;
            end

            else begin
                addrChangeFlag <= 0;
            end
            
        end

    /* CMP STUFF */
        always @(posedge CMP_CFL_) begin

            if (REGS_ [cmdArgs [8:15]] > REGS_ [cmdArgs [16:23]]) begin
                CMP_GG_FL_ <= 1;
            end

            else begin
                CMP_GG_FL_ <= 0;
            end

        end

        always @(posedge CMP_CFL_) begin

            if (REGS_ [cmdArgs [9:16]] === REGS_ [cmdArgs [16:23]]) begin
                CMP_EQ_FL_ <= 1;
            end

            else begin
                CMP_EQ_FL_ <= 0;
            end

        end

    /* ADD & MOV STUFF */
        wire [31:0] WRITE_NUM_ = cmdArgs [63:32];
        wire [7:0]  WRITE_REG_ = cmdArgs [15:8];
        wire   WRITE_NUM_MODE_ = cmdArgs [16];
        wire   WRITE_MEM_MODE_ = cmdArgs [17];

        wire [31:0] READ_NUM_ = cmdArgs [95:64];
        wire [7:0]  READ_REG_ = cmdArgs [27:20];
        wire   READ_NUM_MODE_ = cmdArgs [28];
        wire   READ_MEM_MODE_ = cmdArgs [29];

        wire [1:0] READ_MODE_;
        READ_MODE_ [0] = READ_MEM_MODE_;
        READ_MODE_ [1] = READ_NUM_MODE_;

      /* regs write stuff */
        always @(posedge ADD_CFL_ or posedge MOV_CFL_) begin

            if (ADD_CFL_)
                reg2Write <= REGS_ [cmdArgs [9:16]] + REGS_ [cmdArgs [16:23]];

            if (MOV_CFL_)
                if (~WRITE_MEM_MODE_) begin

                    case (READ_MODE_)

                    2'b00: reg2Write <= REGS_ [READ_REG_];
                    2'b01: reg2Write <= READ_NUM_;
                    2'b10: reg2Write <= MEM_  [READ_REG_];
                    2'b11: reg2Write <= MEM_  [READ_NUM_];

                    endcase

                end

        end

        always @(posedge ADD_CFL_ or posedge MOV_CFL_) begin

            if (ADD_CFL_)
                regId2Write <= cmdArgs [24:31];

            if (MOV_CFL_ && ~WRITE_MEM_MODE_)
                regId2Write <= WRITE_REG_;

        end

      /* mem write stuff */
        always @(posedge MOV_CFL_) begin

            if (WRITE_MEM_MODE_) begin

                case (READ_MODE)

                2'b00: mem2Write <= REGS_ [READ_REG_];
                2'b01: mem2Write <= READ_NUM_;
                2'b10: mem2Write <= MEM_  [READ_REG_];
                2'b11: mem2Write <= MEM_  [READ_NUM_];

                endcase

            end

        end

        always @(posedge MOV_CFL) begin

            if (WRITE_MEM_MODE_) begin

                if (WRITE_NUM_MODE_)
                    memId2Write <= WRITE_NUM_;

                else
                    memId2Write <= WRITE_REG_;

            end

        end

      /* update flags stuff */
        always @(posedge cmdFlags) begin

            if (ADD_CFL_ || (MOV_CFL_ && ~WRITE_MEM_MODE_))
                regWriteFl <= 1;

            else
                regWriteFl <= 0;

        end


        always @(posedge cmdFlags) begin

            if (MOV_CFL_ && WRITE_MEM_MODE_)
                memWriteFl <= 1;

            else
                memWriteFl <= 0;

        end

      /* write stuff */

      always @(posedge memWriteFl) begin

          MEM_ [memId2Write] <= mem2Wirte;

      end

      always @(posedge regWriteFl) begin

          REGS_ [regId2Write] <= reg2Write;

      end

endmodule