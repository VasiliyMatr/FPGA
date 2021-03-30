
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
            /* dataA driver */
            always @(clkA) begin
                /* if there is new data and A domain part is ready to receive data */
                if (send && ready)
                    dataA <= inData;
            end
            /* ready driver */
            always @(clkA) begin
                /* if there is new data and A domain part is ready to receive data */
                if (send && ready)
                    ready <= 0;
                /* if all system is ready */
                else if (~acknowlege [0] && ~enable [2])
                    ready <= 1;
            end

            /* enable driver */
            always @(clkA) begin
                /* if there is new data and A domain part is ready to receive data */
                if (send && ready)
                    enable [2] <= 1;
                /* if A domain part received acknowlege signal */
                else if (acknowlege [0])
                    enable [2] <= 0;
            end

    /* B domain */
        /* dataB driver */
            always @(posedge clkB) begin
                /* if B domain part receive cmd to read data */
                if (enable [0] && ~acknowlege [2])
                    dataB <= dataA;      
            end
        /* acknowlege driver */
            always @(posedge clkB) begin
                /* if we got enable */
                if (enable [0] && ~acknowlege [2])
                    acknowlege  [2] <= 1;
                /* if B domain part should drop acknowlege */
                else if (acknowlege [2] && enable [0])
                    acknowlege  [2] <= 0;
            end

endmodule