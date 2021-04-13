
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
    /* Acknowlege input - from external B domain data reader */
        input wire  acknIn                      ,

    /* B domain outputs (clocked with clkB) */
        output reg  [DATA_SIZE_ - 1:0] out      ,
    /* Enable out - for external B domain data reader */
        output wire enOut

);

/* There is extra registers for metastabiliy errors fix */

    /* internal flags */
        /* read enable flag for B domain */
        reg enable     [2:0];
        /* acknowlege flag  for A domain*/
        reg acknowlege [2:0];

    /* domains data registers */
        reg [DATA_SIZE_ - 1:0] dataA;
        reg [DATA_SIZE_ - 1:0] dataB;

    /* all inits */
        initial begin
            enable [0]      = 01'b0;
            enable [1]      = 01'b0;
            enable [2]      = 01'b0;

            acknowlege [0]  = 01'b0;
            acknowlege [1]  = 01'b0;
            acknowlege [2]  = 01'b0;

            dataA           = DATA_SIZE_ - 1 'b0;
            dataB           = DATA_SIZE_ - 1 'b0;

            ready           = 01'b1;
            out             = 01'b0;
        end

        assign enOut = enable [0];

    /* for no errors with metastability */
        always @(posedge clkB) begin out <= dataB;                      end
        
      /* 0 indexes are used for receive regs; 2 indexes are used for send regs */
        always @(posedge clkB) begin enable [0] <= enable [1];          end
        always @(posedge clkB) begin enable [1] <= enable [2];          end

        always @(posedge clkA) begin acknowlege [0] <= acknowlege [1];  end
        always @(posedge clkA) begin acknowlege [1] <= acknowlege [2];  end
        always @(posedge clkA) begin acknowlege [2] <= acknIn;          end

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

endmodule