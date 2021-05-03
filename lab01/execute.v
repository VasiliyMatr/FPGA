
module Executor   #(

    /* words size in bits */
    parameter WORD_SIZE_            = 32    ,
    /* addr size */
    parameter ADDR_SIZE_            = 32    ,
    /* num or words in RAM memory block */
    parameter WORDS_NUM_            = 4096

)
(

    /* execution flag - posege used for work */
    input wire EXEC_FL_                                     ,

    /* cmds flags */
    input wire [05 : 00] CMD_FL_                            ,
    /* executable cmd args */
    input wire [WORD_SIZE_ * 3 - 1 : 00] CMD_ARG_           ,

    /* ready to execute next cmd flag */
    output reg READY_FL_ = 1                                ,
    /* need to change addr flag */
    output reg JMP_FL_ = 0                                  ,
    /* new execution addr offset */
    output wire [ADDR_SIZE_ - 1 : 00] NEW_EXEC_ADDR_OFF_

);

  /* CMDS FLAGS */
    wire MOV_CFL_ = CMD_FL_ [5 : 5];
    wire ADD_CFL_ = CMD_FL_ [4 : 4];
    wire CMP_CFL_ = CMD_FL_ [3 : 3];

    wire JMP_CFL_ = CMD_FL_ [2 : 2];
    wire JEQ_CFL_ = CMD_FL_ [1 : 1];
    wire JGG_CFL_ = CMD_FL_ [0 : 0];

  /* MOV MODIFIERS */
    /* WRITE PART */
    wire [31 :  00] WRITE_NUM_ = CMD_ARG_ [63 : 32]; /* write part number */
    wire [07 :  00] WRITE_REG_ = CMD_ARG_ [15 : 08]; /* write part register id */
    wire WRITE_NUM_MODE_ = CMD_ARG_ [16 : 16]; /* using number in write part */
    wire WRITE_MEM_MODE_ = CMD_ARG_ [17 : 17]; /* writing to memory */

    /* READ PART */
    wire [31 : 00] READ_NUM_ = CMD_ARG_ [95 : 64]; /* read part number */
    wire [07 : 00] READ_REG_ = CMD_ARG_ [27 : 20]; /* read part register */
    wire READ_NUM_MODE_ = CMD_ARG_ [28 : 28]; /* using number in read part */
    wire READ_MEM_MODE_ = CMD_ARG_ [29 : 29]; /* reading from memory */
    /* read mode for case constr */
    wire [01 : 00] READ_MODE_;
        assign READ_MODE_ [0] = READ_MEM_MODE_;
        assign READ_MODE_ [1] = READ_NUM_MODE_;

  /* CMP FLAGS */
    /* cmp equal flag */
    reg eqFlag = 0;
    /* cmp greater flag */
    reg ggFlag = 0;

  /* REGISTERS */
    reg [WORD_SIZE_ - 1 : 00] registers [31 : 00];

    wire [WORD_SIZE_ - 1 : 00] tmp = registers [2];

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

    initial begin

        eqFlag = 0;
        ggFlag = 0;

        regWrFlag = 0;
        memWrFlag = 0;

        regWrBuff = 0;
        memWrBuff = 0;

        regWrId   = 0;
        memWrAddr = 0;

        registers [00] = 0;
        registers [01] = 0;
        registers [02] = 2;
        registers [03] = 0;
        registers [04] = 0;
        registers [05] = 0;
        registers [06] = 0;
        registers [07] = 0;
        registers [08] = 0;
        registers [09] = 0;
        registers [10] = 0;
        registers [11] = 0;
        registers [12] = 0;
        registers [13] = 0;
        registers [14] = 0;
        registers [15] = 0;
        registers [16] = 0;
        registers [17] = 0;
        registers [18] = 0;
        registers [19] = 0;
        registers [20] = 0;
        registers [21] = 0;
        registers [22] = 0;
        registers [23] = 0;
        registers [24] = 0;
        registers [25] = 0;
        registers [26] = 0;
        registers [27] = 0;
        registers [28] = 0;
        registers [29] = 0;
        registers [30] = 0;
        registers [31] = 0;

        $readmemh ("MEM.txt", memory);
    end

  /* READY FLAG STUFF */
        always @(posedge EXEC_FL_ or posedge regWrFlag or posedge memWrFlag) begin

            if (JMP_CFL_ || JEQ_CFL_  || JGG_CFL_ || CMP_CFL_ ||
                     regWrFlag || memWrFlag)
                READY_FL_ <= 1;

            else
                READY_FL_ <= 0;

        end

  /* JUMPS STUFF */
    /* addr read */
        assign NEW_EXEC_ADDR_OFF_ = CMD_ARG_ [WORD_SIZE_ * 2 - 1 : WORD_SIZE_];

    /* addr chng flag control */
        always @(posedge EXEC_FL_) begin

            if (JMP_CFL_ || (JEQ_CFL_ && eqFlag) || (JGG_CFL_ && ggFlag)) begin
                JMP_FL_ <= 1;
            end

            else begin
                JMP_FL_ <= 0;
            end
            
        end

  /* CMP STUFF */
    /* cmp gg flag control */
        always @(posedge EXEC_FL_) begin
        if (CMP_CFL_) begin

            if (registers [CMD_ARG_ [15 : 08]] > registers [CMD_ARG_ [23 : 16]]) begin
                ggFlag <= 1;
            end

            else begin
                ggFlag <= 0;
            end

        end
        end

    /* cmp eq flag control */
        always @(posedge EXEC_FL_) begin
        if (CMP_CFL_) begin

            if (registers [CMD_ARG_ [15 : 08]] === registers [CMD_ARG_ [23 : 16]]) begin
                eqFlag <= 1;
            end

            else begin
                eqFlag <= 0;
            end

        end
        end

  /* ADD & MOV STUFF */
    /* regs write stuff */
        always @(posedge EXEC_FL_) begin
        if (ADD_CFL_ || MOV_CFL_) begin

            if (ADD_CFL_)
                regWrBuff <= registers [CMD_ARG_ [15 : 08]] +
                             registers [CMD_ARG_ [23 : 16]];

            if (MOV_CFL_)
                if (~WRITE_MEM_MODE_) begin

                    if (READ_MODE_ === 2'b00) regWrBuff <= registers [READ_REG_]; else
                    if (READ_MODE_ === 2'b01) regWrBuff <= READ_NUM_; else
                    if (READ_MODE_ === 2'b10) regWrBuff <= memory  [READ_REG_]; else
                    if (READ_MODE_ === 2'b11) regWrBuff <= memory  [READ_NUM_];

                end

        end
        end

        always @(posedge EXEC_FL_) begin
        if (ADD_CFL_ || MOV_CFL_) begin

            if (ADD_CFL_)
                regWrId <= CMD_ARG_ [31 : 24];

            if (MOV_CFL_ && ~WRITE_MEM_MODE_)
                regWrId <= WRITE_REG_;

        end
        end

      /* mem write stuff */
        always @(posedge EXEC_FL_) begin
        if (MOV_CFL_) begin

            if (WRITE_MEM_MODE_) begin

                if (READ_MODE_ === 2'b00) memWrBuff <= registers [READ_REG_]; else
                if (READ_MODE_ === 2'b01) memWrBuff <= READ_NUM_; else
                if (READ_MODE_ === 2'b10) memWrBuff <= memory  [READ_REG_]; else
                if (READ_MODE_ === 2'b11) memWrBuff <= memory  [READ_NUM_];

            end

        end
        end

        always @(posedge EXEC_FL_) begin
        if (MOV_CFL_) begin

            if (WRITE_MEM_MODE_) begin

                if (WRITE_NUM_MODE_)
                    memWrAddr <= WRITE_NUM_;

                else
                    memWrAddr <= registers [WRITE_REG_];

            end

        end
        end

    /* update mem & reg write flags */
        always @(posedge EXEC_FL_) begin

            regWrFlag <= ADD_CFL_ || (MOV_CFL_ && ~WRITE_MEM_MODE_);

        end

        always @(negedge EXEC_FL_) begin

            regWrFlag <= 0;

        end

        always @(posedge EXEC_FL_) begin

            memWrFlag <= MOV_CFL_ && WRITE_MEM_MODE_;

        end

        always @(negedge EXEC_FL_) begin

            memWrFlag <= 0;

        end

    /* reg & mem write stuff */
        always @(posedge memWrFlag) begin

            memory [memWrAddr] <= memWrBuff;

        end

        always @(posedge regWrFlag) begin

            registers [regWrId] <= regWrBuff;

        end

endmodule