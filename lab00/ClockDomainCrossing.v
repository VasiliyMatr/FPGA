
module CDCHandler (

    /* domains clocks */
    input wire  CLKa                ,
    input wire  CLKb                ,

    /* a inputs */
    input wire  [15:0] aDataIn      ,
    input wire  aSend               ,

    /* a outputs */
    output reg  aReady              ,

    /* b outputs */
    output reg [15:0] bOut

);
    /* internal flags */
        /* read enable flag */
        reg [2:0] aEnable;
        /* acknowlege flag */
        reg [2:0] bAcn;

    /* domains data */
        reg [15:0] aData;
        reg [15:0] bData;

        initial begin
            aEnable   = 03'b0;
            bAcn      = 03'b0;
            aData     = 16'b0;
            aReady    = 0;

            bData     = 16'b0;

            bOut      = 16'b0;
        end

    /* for no errors with metastability : 0 is for receive; 2 is for send */
        always @(posedge CLKb) begin bOut <= bData;              end
        
        always @(posedge CLKb) begin aEnable [0] <= aEnable [1]; end
        always @(posedge CLKb) begin aEnable [1] <= aEnable [2]; end

        always @(posedge CLKa) begin bAcn [0] <= bAcn [1];       end
        always @(posedge CLKa) begin bAcn [1] <= bAcn [2];       end

    /* a domain */
        /* if there is new data and a-part is ready to receive data */
            always @(posedge aSend) begin
                if (aReady) aData <= aDataIn;
            end
            always @(posedge aSend) begin
                aReady <= 0;
            end
            always @(posedge aSend) begin
                if (aReady) aEnable [2] <= 1;
            end

        /* if a-part received acknowlege signal */
            always @(posedge bAcn [0]) begin
                aEnable [2] <= 0;
            end

        /* if a-part received acknowlege signal drop */
            always @(negedge bAcn [0]) begin
                aReady <= 1;
            end

    /* b domain */
        /* if b-part receive cmd to read data */
            always @(posedge aEnable [0]) begin
                bData     <= aData;
                bAcn  [2] <= 1;       
            end
        /* if b-part should drop acknowlege */
            always @(negedge aEnable [0]) begin
                bAcn  [2] <= 0;
            end

endmodule