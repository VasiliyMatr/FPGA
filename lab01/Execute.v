
`define _WORD_SIZE 32
`define _ADDR_SIZE 32
`define _MEM_SIZE  16

module Executor (

    /* clock */
    input wire CLK_                                         ,
    /* execution flag */
    input wire EXEC_FL_                                     ,

    /* cmds flags */
    input wire [05 : 00] CMD_FLGS_                            ,
    /* executable cmd args */
    input wire [`_WORD_SIZE * 3 - 1 : 00] CMD_ARG_           ,

    /* ready to execute next cmd flag */
    output reg READY_FL_ = 0                                ,
    /* need to change addr flag */
    output reg JMP_FL_ = 0                                  ,
    /* new execution addr offset */
    output wire [`_ADDR_SIZE - 1 : 00] NEW_EXEC_ADDR_OFF_    ,

    output wire [`_WORD_SIZE * 4 - 1 : 00] DUMP_

);

  /* CMDS FLAGS */
    wire MOV_CFL_ = CMD_FLGS_ [5 : 5];
    wire ADD_CFL_ = CMD_FLGS_ [4 : 4];
    wire CMP_CFL_ = CMD_FLGS_ [3 : 3];

    wire JMP_CFL_ = CMD_FLGS_ [2 : 2];
    wire JEQ_CFL_ = CMD_FLGS_ [1 : 1];
    wire JGG_CFL_ = CMD_FLGS_ [0 : 0];


  /* JMP ADDR */
    assign NEW_EXEC_ADDR_OFF_ = CMD_ARG_ [63 : 32];

  /* MOV ARGS STUFF */
    /* WRITE PART */
    wire [`_WORD_SIZE :  00] WRITE_NUM_ = CMD_ARG_ [63 : 32]; /* write part number */
    wire [07 :  00] WRITE_REG_ = CMD_ARG_ [15 : 08]; /* write part register id */
    wire WRITE_NUM_MODE_ = CMD_ARG_ [16 : 16]; /* using number in write part */
    wire WRITE_MEM_MODE_ = CMD_ARG_ [17 : 17]; /* writing to memory */

    /* READ PART */
    wire [`_WORD_SIZE : 00] READ_NUM_ = CMD_ARG_ [95 : 64]; /* read part number */
    wire [07 : 00] READ_REG_ = CMD_ARG_ [27 : 20]; /* read part register */
    wire READ_NUM_MODE_ = CMD_ARG_ [28 : 28]; /* using number in read part */
    wire READ_MEM_MODE_ = CMD_ARG_ [29 : 29]; /* reading from memory */

    /* READ MODE */
    wire [01 : 00] READ_MODE_;
        assign READ_MODE_ [1] = READ_MEM_MODE_;
        assign READ_MODE_ [0] = READ_NUM_MODE_;

  /* CMP FLAGS */
    /* cmp equal flag */
    reg eqFlag = 0;
    /* cmp greater flag */
    reg ggFlag = 0;

  /* REGISTERS */
    reg [`_WORD_SIZE - 1 : 00] registers [31 : 00];

  /* RAM */
    reg [`_WORD_SIZE - 1 : 00] memory [`_MEM_SIZE - 1 : 00];

  /* DEBUG STUFF */
    assign DUMP_ [31  : 00] = memory [0];
    assign DUMP_ [63  : 32] = memory [1];
    assign DUMP_ [95  : 64] = memory [2];
    assign DUMP_ [127 : 96] = memory [3];

  /* REGS & MEM WRITES STUFF */
    /* write flags */
    reg regWrFlag = 0;
    reg memWrFlag = 0;

    /* read tmp buffs */
    reg [`_WORD_SIZE - 1 : 00] regWrBuff = 0;
    reg [`_WORD_SIZE - 1 : 00] memWrBuff = 0;

    /* reg write id & mem write addr */
    reg [04 : 00] regWrId = 0;
    reg [`_ADDR_SIZE - 1 : 00] memWrAddr = 0;

  /* REGS & FLAGS & MEM INIT */
    initial begin

        eqFlag = 0;
        ggFlag = 0;

        regWrFlag = 0;
        memWrFlag = 0;

        regWrBuff = 0;
        memWrBuff = 0;

        regWrId   = 0;
        memWrAddr = 0;

        $readmemh ("MEM.txt", registers);
        $readmemh ("MEM.txt", memory);

    end

  /* READY FLAG STUFF */
        always @(negedge CLK_) begin

            if (EXEC_FL_ && ~READY_FL_) begin
                READY_FL_ <=
                JMP_CFL_ || JEQ_CFL_  || JGG_CFL_ || CMP_CFL_ || regWrFlag || memWrFlag;
            end

            else READY_FL_ <= 0;

        end

  /* JUMPS STUFF */

    /* addr chng flag control */
        always @(negedge CLK_) begin

            if (EXEC_FL_)
                JMP_FL_ <= JMP_CFL_ || (JEQ_CFL_ && eqFlag) || (JGG_CFL_ && ggFlag);

            else
                JMP_FL_ <= 0;

        end

  /* CMP STUFF */
    /* cmp gg flag control */
        always @(negedge CLK_) begin
        if (EXEC_FL_ && CMP_CFL_) begin

            if (registers [CMD_ARG_ [15 : 08]] > registers [CMD_ARG_ [23 : 16]]) begin
                ggFlag <= 1;
            end

            else begin
                ggFlag <= 0;
            end

        end
        end

    /* cmp eq flag control */
        always @(negedge CLK_) begin
        if (EXEC_FL_ && CMP_CFL_) begin

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
        always @(negedge CLK_) begin
        if (EXEC_FL_ && (ADD_CFL_ || MOV_CFL_)) begin

            if (ADD_CFL_)
                regWrBuff <= registers [CMD_ARG_ [15 : 08]] +
                             registers [CMD_ARG_ [23 : 16]];

            if (MOV_CFL_)
                if (~WRITE_MEM_MODE_) begin

                    if (READ_MODE_ === 2'b00) regWrBuff <= registers [READ_REG_]; else
                    if (READ_MODE_ === 2'b01) regWrBuff <= READ_NUM_; else
                    if (READ_MODE_ === 2'b10) regWrBuff <= memory  [registers [READ_REG_]]; else
                    if (READ_MODE_ === 2'b11) regWrBuff <= memory  [READ_NUM_];

                end

        end
        end

        always @(negedge CLK_) begin
        if (EXEC_FL_ && (ADD_CFL_ || MOV_CFL_)) begin

            if (ADD_CFL_)
                regWrId <= CMD_ARG_ [31 : 24];

            if (MOV_CFL_ && ~WRITE_MEM_MODE_)
                regWrId <= WRITE_REG_;

        end
        end

      /* mem write stuff */
        always @(negedge CLK_) begin
        if (EXEC_FL_ && MOV_CFL_) begin

            if (WRITE_MEM_MODE_) begin

                if (READ_MODE_ === 2'b00) memWrBuff <= registers [READ_REG_]; else
                if (READ_MODE_ === 2'b01) memWrBuff <= READ_NUM_; else
                if (READ_MODE_ === 2'b10) memWrBuff <= memory  [registers [READ_REG_]]; else
                if (READ_MODE_ === 2'b11) memWrBuff <= memory  [READ_NUM_];

            end

        end
        end

        always @(negedge CLK_) begin
        if (EXEC_FL_ && MOV_CFL_) begin

            if (WRITE_MEM_MODE_) begin

                if (WRITE_NUM_MODE_)
                    memWrAddr <= WRITE_NUM_;

                else
                    memWrAddr <= registers [WRITE_REG_];

            end

        end
        end

    /* update mem & reg write flags */
        always @(negedge CLK_) begin

            if (~regWrFlag && ~READY_FL_)
                regWrFlag <= ADD_CFL_ || (MOV_CFL_ && ~WRITE_MEM_MODE_);
            else
                regWrFlag <= 0;

        end

        always @(negedge CLK_) begin

            if (~memWrFlag && ~READY_FL_)
                memWrFlag <= MOV_CFL_ && WRITE_MEM_MODE_;
            else
                memWrFlag <= 0;

        end

    /* reg & mem write stuff */
        always @(negedge CLK_) begin

            if (memWrFlag)
                memory [memWrAddr] <= memWrBuff;

        end

        always @(negedge CLK_) begin

            if (regWrFlag)
                registers [regWrId] <= regWrBuff;

        end

endmodule