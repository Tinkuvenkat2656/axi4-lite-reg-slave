module axi4lite_reg_slave #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    input  logic                      ACLK,
    input  logic                      ARESETn,

    input  logic [ADDR_WIDTH-1:0]     AWADDR,
    input  logic                      AWVALID,
    output logic                      AWREADY,

    input  logic [DATA_WIDTH-1:0]     WDATA,
    input  logic [(DATA_WIDTH/8)-1:0] WSTRB,
    input  logic                      WVALID,
    output logic                      WREADY,

    output logic [1:0]                BRESP,
    output logic                      BVALID,
    input  logic                      BREADY,

    input  logic [ADDR_WIDTH-1:0]     ARADDR,
    input  logic                      ARVALID,
    output logic                      ARREADY,

    output logic [DATA_WIDTH-1:0]     RDATA,
    output logic [1:0]                RRESP,
    output logic                      RVALID,
    input  logic                      RREADY
);

  logic [31:0] reg0, reg1, reg2, reg3;

  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      reg0    <= 32'h0;
      reg1    <= 32'h0;
      reg2    <= 32'h0;
      reg3    <= 32'h0;
      AWREADY <= 1'b0;
      WREADY  <= 1'b0;
      BVALID  <= 1'b0;
      BRESP   <= 2'b00;
    end
    else begin
      AWREADY <= 1'b0;
      WREADY  <= 1'b0;

      if (AWVALID && WVALID && !BVALID) begin
        AWREADY <= 1'b1;
        WREADY  <= 1'b1;

        case (AWADDR)
          4'h0: begin
            if (WSTRB[0]) reg0[7:0]   <= WDATA[7:0];
            if (WSTRB[1]) reg0[15:8]  <= WDATA[15:8];
            if (WSTRB[2]) reg0[23:16] <= WDATA[23:16];
            if (WSTRB[3]) reg0[31:24] <= WDATA[31:24];
          end
          4'h4: begin
            if (WSTRB[0]) reg1[7:0]   <= WDATA[7:0];
            if (WSTRB[1]) reg1[15:8]  <= WDATA[15:8];
            if (WSTRB[2]) reg1[23:16] <= WDATA[23:16];
            if (WSTRB[3]) reg1[31:24] <= WDATA[31:24];
          end
          4'h8: begin
            if (WSTRB[0]) reg2[7:0]   <= WDATA[7:0];
            if (WSTRB[1]) reg2[15:8]  <= WDATA[15:8];
            if (WSTRB[2]) reg2[23:16] <= WDATA[23:16];
            if (WSTRB[3]) reg2[31:24] <= WDATA[31:24];
          end
          4'hC: begin
            if (WSTRB[0]) reg3[7:0]   <= WDATA[7:0];
            if (WSTRB[1]) reg3[15:8]  <= WDATA[15:8];
            if (WSTRB[2]) reg3[23:16] <= WDATA[23:16];
            if (WSTRB[3]) reg3[31:24] <= WDATA[31:24];
          end
          default: ;
        endcase

        BVALID <= 1'b1;
        BRESP  <= 2'b00;
      end
      else if (BVALID && BREADY) begin
        BVALID <= 1'b0;
      end
    end
  end

  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      ARREADY <= 1'b0;
      RVALID  <= 1'b0;
      RRESP   <= 2'b00;
      RDATA   <= 32'h0;
    end
    else begin
      ARREADY <= 1'b0;

      if (ARVALID && !RVALID) begin
        ARREADY <= 1'b1;
        RVALID  <= 1'b1;
        RRESP   <= 2'b00;

        case (ARADDR)
          4'h0: RDATA <= reg0;
          4'h4: RDATA <= reg1;
          4'h8: RDATA <= reg2;
          4'hC: RDATA <= reg3;
          default: RDATA <= 32'hDEAD_BEEF;
        endcase
      end
      else if (RVALID && RREADY) begin
        RVALID <= 1'b0;
      end
    end
  end

endmodule