module top;
  logic ACLK;
  logic ARESETn;

  axi_if #(
  .ADDR_WIDTH(4),
  .DATA_WIDTH(32)
) vif (
  .ACLK(ACLK),
  .ARESETn(ARESETn)
);

  axi4lite_reg_slave #(
    .ADDR_WIDTH(4),
    .DATA_WIDTH(32)
  ) dut (
    .ACLK    (vif.ACLK),
    .ARESETn (vif.ARESETn),

    .AWADDR  (vif.AWADDR),
    .AWVALID (vif.AWVALID),
    .AWREADY (vif.AWREADY),

    .WDATA   (vif.WDATA),
    .WSTRB   (vif.WSTRB),
    .WVALID  (vif.WVALID),
    .WREADY  (vif.WREADY),

    .BRESP   (vif.BRESP),
    .BVALID  (vif.BVALID),
    .BREADY  (vif.BREADY),

    .ARADDR  (vif.ARADDR),
    .ARVALID (vif.ARVALID),
    .ARREADY (vif.ARREADY),

    .RDATA   (vif.RDATA),
    .RRESP   (vif.RRESP),
    .RVALID  (vif.RVALID),
    .RREADY  (vif.RREADY)
  );

  initial begin
    ACLK = 1'b0;
    forever #5 ACLK = ~ACLK;
  end

  initial begin
    ARESETn = 1'b0;
    repeat (3) @(posedge ACLK);
    ARESETn = 1'b1;
  end

  initial begin
    // Default master-driven signals
    vif.AWADDR  = '0;
    vif.AWVALID = 1'b0;
    vif.WDATA   = '0;
    vif.WSTRB   = '0;
    vif.WVALID  = 1'b0;
    vif.BREADY  = 1'b0;

    vif.ARADDR  = '0;
    vif.ARVALID = 1'b0;
    vif.RREADY  = 1'b0;

    // Wait until reset deasserts
    wait (ARESETn == 1'b1);
    @(posedge ACLK);

      vif.AWADDR  <= 4'h0;
    vif.AWVALID <= 1'b1;
    vif.WDATA   <= 32'hA5A5_1234;
    vif.WSTRB   <= 4'b1111;
    vif.WVALID  <= 1'b1;
    vif.BREADY  <= 1'b1;

    wait (vif.AWREADY && vif.WREADY);
    @(posedge ACLK);

    vif.AWVALID <= 1'b0;
    vif.WVALID  <= 1'b0;

    wait (vif.BVALID);
    @(posedge ACLK);

    $display("[WRITE] AWADDR = 0x%0h, WDATA = 0x%08h, BRESP = %0b",
             vif.AWADDR, vif.WDATA, vif.BRESP);

    vif.BREADY <= 1'b0;

    @(posedge ACLK);
    vif.ARADDR  <= 4'h0;
    vif.ARVALID <= 1'b1;
    vif.RREADY  <= 1'b1;

    wait (vif.ARREADY);
    @(posedge ACLK);
    vif.ARVALID <= 1'b0;

    wait (vif.RVALID);
    @(posedge ACLK);

    $display("[READ ] ARADDR = 0x%0h, RDATA = 0x%08h, RRESP = %0b",
             vif.ARADDR, vif.RDATA, vif.RRESP);

    vif.RREADY <= 1'b0;

    repeat (3) @(posedge ACLK);
    $finish;
  end

endmodule
