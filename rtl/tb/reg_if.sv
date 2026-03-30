interface axi_if #(parameter ADDR_WIDTH=4, DATA_WIDTH=32) 
(input logic ACLK, input logic ARESETn);

logic [ADDR_WIDTH-1:0] AWADDR;
logic                  AWVALID;
logic                  AWREADY;

logic [DATA_WIDTH-1:0] WDATA;
logic [(DATA_WIDTH/8)-1:0] WSTRB;
logic                  WVALID;
logic                  WREADY;

logic [1:0]             BRESP;
logic                  BVALID;
logic                  BREADY;

logic [ADDR_WIDTH-1:0] ARADDR;
logic                  ARVALID;
logic                  ARREADY;

logic [DATA_WIDTH-1:0] RDATA;
logic [1:0]            RRESP;
logic                  RVALID;
logic                  RREADY;

modport DUT (
input ACLK, ARESETn,
input AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
output AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID
);

modport DRV (
input ACLK, ARESETn,
input AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID,
output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY
);

modport MON (
input ACLK, ARESETn, AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY, AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID
);
endinterface
