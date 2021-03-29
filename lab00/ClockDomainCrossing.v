
/* Module to transmit data form A clock domain to B clock domain
 */

module CDCHandler #(
    parameter DATA_SIZE_ = 16
)(
  /* A DOMAIN */

    /* A domain inputs (should be clocked with A domain clk signal) */
      /* A domain clock signal */
        input wire  clkA                        ,
      /* input bit sequence to transmit */
        input wire  [DATA_SIZE_ - 1:0] inData   ,
      /* new data send signal */
        input wire  send                        ,

    /* A domain inputs (clocked with clkA) */
      /* ready to transmit new data signal */
        output reg  ready                       ,

  /* B DOMAIN */

    /* B domain inputs */
        input wire  clkB                        ,

    /* B domain outputs (clocked with clkB) */
        output reg  [DATA_SIZE_ - 1:0] out

);

    /* internal flags */
        /* read enable flag for B domain */
        reg [2:0] enable;
        /* acknowlege flag  for A domain*/
        reg [2:0] acknowlege;

    /* domains data registers */
        reg [DATA_SIZE_ - 1:0] dataA;
        reg [DATA_SIZE_ - 1:0] dataB;

    /* all registers init */
        initial begin
            enable          = 03'b0;
            acknowlege      = 03'b0;
            dataA           = 16'b0;
            ready           = 01'b0;

            dataB           = 16'b0;

            out             = 16'b0;
        end

    /* for no errors with metastability */
        always @(posedge clkB) begin out <= dataB;                      end
        
      /* 0 indexes are used for receive regs; 2 indexes are used for send regs */
        always @(posedge clkB) begin enable [0] <= enable [1];          end
        always @(posedge clkB) begin enable [1] <= enable [2];          end

        always @(posedge clkA) begin acknowlege [0] <= acknowlege [1];  end
        always @(posedge clkA) begin acknowlege [1] <= acknowlege [2];  end

    /* A domain */
        /* if there is new data and A domain part is ready to receive data */
            always @(posedge send) begin
                if (ready) dataA <= inData; /* getting new data to transmit */
            end
            always @(posedge send) begin
                ready <= 0; /* ready flag is now zero */
            end
            always @(posedge send) begin
                if (ready) enable [2] <= 1; /* enable flag is now 1 */
            end

        /* if A domain part received acknowlege signal */
            always @(posedge acknowlege [0]) begin
                enable [2] <= 0; /* now enable flag is 0 */
            end

        /* if A domain part received acknowlege signal negedge */
            always @(negedge acknowlege [0]) begin
                ready <= 1; /* ready for next data transmit */
            end

    /* B domain */
        /* if B domain part receive cmd to read data */
            always @(posedge enable [0]) begin
                dataB     <= dataA; /* writing new data to B domain part */       
            end
            always @(posedge enable [0]) begin
                acknowlege  [2] <= 1; /* acknowlege flag in now 1 */
            end
        /* if B domain part should drop acknowlege */
            always @(negedge enable [0]) begin
                acknowlege  [2] <= 0; /* acknowlege is now 0 */
            end

endmodule