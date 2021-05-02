
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
    input wire [5 : 0] CMD_FL_;
    /* executable cmd args */
    input wire [WORD_SIZE_ * 3 - 1 : 0] CMD_ARG_;

    /* ready to execute next cmd flag */
    output reg READY_FL_;
    /* need to change addr flag */
    output reg JMP_FL_;
    /* new execution addr offset */
    output reg [ADDR_SIZE_ - 1 : 0] NEW_EXEC_ADDR_OFF_;

);

  /* CMDS FLAGS */
    wire MOV_CFL_ = CMD_FL_ [0];
    wire ADD_CFL_ = CMD_FL_ [1];
    wire CMP_CFL_ = CMD_FL_ [2];

    wire JMP_CFL_ = CMD_FL_ [3];
    wire JEQ_CFL_ = CMD_FL_ [4];
    wire JGG_CFL_ = CMD_FL_ [5];

  /* MOV MODIFIERS */
    /* WRITE PART */
    wire [31 :  00] WRITE_NUM_ = CMD_ARG_ [63 : 32]; /* write part number */
    wire [07 :  00] WRITE_REG_ = CMD_ARG_ [15 : 08]; /* write part register id */
    wire WRITE_NUM_MODE_ = CMD_ARG_ [16]; /* using number in write part */
    wire WRITE_MEM_MODE_ = CMD_ARG_ [17]; /* writing to memory */

    /* READ PART */
    wire [31 : 00] READ_NUM_ = CMD_ARG_ [95 : 64]; /* read part number */
    wire [07 : 00] READ_REG_ = CMD_ARG_ [27 : 20]; /* read part register */
    wire READ_NUM_MODE_ = CMD_ARG_ [28]; /* using number in read part */
    wire READ_MEM_MODE_ = CMD_ARG_ [29]; /* reading from memory */
    /* read mode for switch */
    wire [01 : 00] READ_MODE_;
        READ_MODE_ [0] = READ_MEM_MODE_;
        READ_MODE_ [1] = READ_NUM_MODE_;

  /* CMP FLAGS */
    /* cmp equal flag */
    reg eqFlag;
    /* cmp greater flag */
    reg ggFlag;

  /* REGISTERS */
    reg [WORD_SIZE_ - 1 : 00] registers [31 : 00];

  /* RAM */
    reg [WORD_SIZE_ - 1 : 00] memory [WORDS_NUM_ - 1 : 00];

  /* REGS & MEM WRITE STUFF */
    /* write flags */
    reg regWrFlag = 0;
    reg memWrFlag = 0;

    /* write tmp buffs */
    reg [WORD_SIZE_ - 1 : 00] regWrBuff = 0;
    reg [WORD_SIZE_ - 1 : 00] memWrBuff = 0;

    /* reg write id & mem write addr */
    reg [04 : 00] regWrId = 0;
    reg [ADDR_SIZE_ - 1 : 00] memWrAddr = 0;

  /* JUMPS STUFF */
        always @(posedge JMP_CFL_ or posedge JEQ_CFL_ or posedge JGG_CFL_) begin

            if (JMP_CFL_ || (JEQ_CFL_ && eqFlag) || (JGG_CFL_ && ggFlag)) begin
                NEW_EXEC_ADDR_OFF_ <= CMD_ARG_ [WORD_SIZE_ * 3 - 9 : WORD_SIZE_ * 2];
            end

        end

        always @(posedge CMD_FL_) begin

            if (JMP_CFL_ || (JEQ_CFL_ && eqFlag) || (JGG_CFL_ && ggFlag)) begin
                JMP_FL_ <= 1;
            end

            else begin
                JMP_FL_ <= 0;
            end
            
        end

  /* CMP STUFF */
        always @(posedge CMP_CFL_) begin

            if (registers [CMD_ARG_ [8:15]] > registers [CMD_ARG_ [16:23]]) begin
                ggFlag <= 1;
            end

            else begin
                ggFlag <= 0;
            end

        end

        always @(posedge CMP_CFL_) begin

            if (registers [CMD_ARG_ [9:16]] === registers [CMD_ARG_ [16:23]]) begin
                eqFlag <= 1;
            end

            else begin
                eqFlag <= 0;
            end

        end

  /* ADD & MOV STUFF */

      /* regs write stuff */
        always @(posedge ADD_CFL_ or posedge MOV_CFL_) begin

            if (ADD_CFL_)
                regWrBuff <= registers [CMD_ARG_ [9:16]] + registers [CMD_ARG_ [16:23]];

            if (MOV_CFL_)
                if (~WRITE_MEM_MODE_) begin

                    case (READ_MODE_)

                    2'b00: regWrBuff <= registers [READ_REG_];
                    2'b01: regWrBuff <= READ_NUM_;
                    2'b10: regWrBuff <= memory  [READ_REG_];
                    2'b11: regWrBuff <= memory  [READ_NUM_];

                    endcase

                end

        end

        always @(posedge ADD_CFL_ or posedge MOV_CFL_) begin

            if (ADD_CFL_)
                regWrId <= CMD_ARG_ [24:31];

            if (MOV_CFL_ && ~WRITE_MEM_MODE_)
                regWrId <= WRITE_REG_;

        end

      /* mem write stuff */
        always @(posedge MOV_CFL_) begin

            if (WRITE_MEM_MODE_) begin

                case (READ_MODE)

                2'b00: mem2Write <= registers [READ_REG_];
                2'b01: mem2Write <= READ_NUM_;
                2'b10: mem2Write <= memory  [READ_REG_];
                2'b11: mem2Write <= memory  [READ_NUM_];

                endcase

            end

        end

        always @(posedge MOV_CFL) begin

            if (WRITE_MEM_MODE_) begin

                if (WRITE_NUM_MODE_)
                    memWrAddr <= WRITE_NUM_;

                else
                    memWrAddr <= WRITE_REG_;

            end

        end

      /* update flags stuff */
        always @(posedge CMD_FL_) begin

            if (ADD_CFL_ || (MOV_CFL_ && ~WRITE_MEM_MODE_))
                regWrFlag <= 1;

            else
                regWrFlag <= 0;

        end


        always @(posedge CMD_FL_) begin

            if (MOV_CFL_ && WRITE_MEM_MODE_)
                memWrFlag <= 1;

            else
                memWrFlag <= 0;

        end

      /* write stuff */

      always @(posedge memWrFlag) begin

          memory [memWrAddr] <= memWrBuff;

      end

      always @(posedge regWrFlag) begin

          registers [regWrId] <= regWrBuff;

      end

endmodule