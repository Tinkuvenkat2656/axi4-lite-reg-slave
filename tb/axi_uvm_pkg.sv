package axi_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum {OP_WRITE, OP_READ} axi_op_t;

  class axi_txn extends uvm_sequence_item;
    `uvm_object_utils(axi_txn)

    axi_op_t   op;
    bit [3:0]  addr;
    bit [31:0] data;
    bit [3:0]  wstrb;
    bit [31:0] rdata;
    bit [1:0]  resp;

    function new(string name = "axi_txn");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("op=%s addr=0x%0h data=0x%08h wstrb=0x%0h rdata=0x%08h resp=%0b",
                       (op == OP_WRITE) ? "WRITE" : "READ",
                       addr, data, wstrb, rdata, resp);
    endfunction
  endclass


  class axi_write_seq extends uvm_sequence #(axi_txn);
    `uvm_object_utils(axi_write_seq)

    function new(string name = "axi_write_seq");
      super.new(name);
    endfunction

    virtual task body();
      axi_txn tr;
      tr = axi_txn::type_id::create("tr");

      start_item(tr);
      tr.op    = OP_WRITE;
      tr.addr  = 4'h0;
      tr.data  = 32'hA5A5_1234;
      tr.wstrb = 4'hF;
      `uvm_info("WRITE_SEQ", tr.convert2string(), UVM_MEDIUM)
      finish_item(tr);
    endtask
  endclass


  class axi_read_seq extends uvm_sequence #(axi_txn);
    `uvm_object_utils(axi_read_seq)

    function new(string name = "axi_read_seq");
      super.new(name);
    endfunction

    virtual task body();
      axi_txn tr;
      tr = axi_txn::type_id::create("tr");

      start_item(tr);
      tr.op    = OP_READ;
      tr.addr  = 4'h0;
      tr.data  = 32'h0;
      tr.wstrb = 4'h0;
      `uvm_info("READ_SEQ", tr.convert2string(), UVM_MEDIUM)
      finish_item(tr);
    endtask
  endclass


  class axi_sequencer extends uvm_sequencer #(axi_txn);
    `uvm_component_utils(axi_sequencer)

    function new(string name = "axi_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass


  class axi_driver extends uvm_driver #(axi_txn);
    `uvm_component_utils(axi_driver)

    virtual axi_if.DRV vif;

    function new(string name = "axi_driver", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual axi_if.DRV)::get(this, "", "vif", vif))
        `uvm_fatal("DRV", "virtual interface not set for axi_driver")
    endfunction

    task run_phase(uvm_phase phase);
      axi_txn tr;

      set_defaults();

      wait (vif.ARESETn == 1'b1);
      @(posedge vif.ACLK);

      forever begin
        seq_item_port.get_next_item(tr);

        case (tr.op)
          OP_WRITE: drive_write(tr);
          OP_READ : drive_read(tr);
          default : `uvm_error("DRV", "Unknown transaction op")
        endcase

        seq_item_port.item_done();
      end
    endtask

    task set_defaults();
      vif.AWADDR  <= '0;
      vif.AWVALID <= 0;
      vif.WDATA   <= '0;
      vif.WSTRB   <= '0;
      vif.WVALID  <= 0;
      vif.BREADY  <= 0;
      vif.ARADDR  <= '0;
      vif.ARVALID <= 0;
      vif.RREADY  <= 0;
    endtask

    task drive_write(axi_txn tr);
      @(posedge vif.ACLK);

      vif.AWADDR  <= tr.addr;
      vif.AWVALID <= 1;
      vif.WDATA   <= tr.data;
      vif.WSTRB   <= tr.wstrb;
      vif.WVALID  <= 1;
      vif.BREADY  <= 0;

      do @(posedge vif.ACLK);
      while (!(vif.AWREADY && vif.WREADY));

      vif.AWVALID <= 0;
      vif.WVALID  <= 0;

      do @(posedge vif.ACLK);
      while (!vif.BVALID);

      tr.resp = vif.BRESP;
      vif.BREADY <= 1;

      @(posedge vif.ACLK);
      vif.BREADY <= 0;
    endtask

    task drive_read(axi_txn tr);
      @(posedge vif.ACLK);

      vif.ARADDR  <= tr.addr;
      vif.ARVALID <= 1;
      vif.RREADY  <= 0;

      do @(posedge vif.ACLK);
      while (!vif.ARREADY);

      vif.ARVALID <= 0;

      do @(posedge vif.ACLK);
      while (!vif.RVALID);

      tr.rdata = vif.RDATA;
      tr.resp  = vif.RRESP;
      vif.RREADY <= 1;

      @(posedge vif.ACLK);
      vif.RREADY <= 0;
    endtask

  endclass


  class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    virtual axi_if.MON vif;
    uvm_analysis_port #(axi_txn) mon_ap;

    function new(string name = "axi_monitor", uvm_component parent = null);
      super.new(name, parent);
      mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual axi_if.MON)::get(this, "", "vif", vif))
        `uvm_fatal("MON", "Failed to get virtual interface in monitor")
    endfunction

    task run_phase(uvm_phase phase);
      axi_txn tr;

      forever begin
        @(posedge vif.ACLK);

        if (!vif.ARESETn)
          continue;

        if (vif.AWVALID && vif.WVALID && vif.AWREADY && vif.WREADY) begin
          tr = axi_txn::type_id::create("wr_tr", this);
          tr.op    = OP_WRITE;
          tr.addr  = vif.AWADDR;
          tr.data  = vif.WDATA;
          tr.wstrb = vif.WSTRB;

          @(posedge vif.ACLK);
          if (vif.BVALID)
            tr.resp = vif.BRESP;
          else
            tr.resp = 2'b00;

          mon_ap.write(tr);
          `uvm_info("MON", $sformatf("WRITE MONITORED: %s", tr.convert2string()), UVM_MEDIUM)
        end

        if (vif.ARVALID && vif.ARREADY) begin
          tr = axi_txn::type_id::create("rd_tr", this);
          tr.op   = OP_READ;
          tr.addr = vif.ARADDR;
          tr.wstrb = 4'h0;

          @(posedge vif.ACLK);
          if (vif.RVALID) begin
            tr.rdata = vif.RDATA;
            tr.resp  = vif.RRESP;
            mon_ap.write(tr);
            `uvm_info("MON", $sformatf("READ MONITORED: %s", tr.convert2string()), UVM_MEDIUM)
          end
        end
      end
    endtask

  endclass


  class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    uvm_analysis_imp #(axi_txn, axi_scoreboard) sb_imp;

    bit [31:0] reg0, reg1, reg2, reg3;

    function new(string name = "axi_scoreboard", uvm_component parent = null);
      super.new(name, parent);
      sb_imp = new("sb_imp", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      reg0 = 32'h0;
      reg1 = 32'h0;
      reg2 = 32'h0;
      reg3 = 32'h0;
    endfunction

    function void write(axi_txn tr);
      bit [31:0] expected_data;

      if (tr.op == OP_WRITE) begin
        case (tr.addr)
          4'h0: begin
            if (tr.wstrb[0]) reg0[7:0]   = tr.data[7:0];
            if (tr.wstrb[1]) reg0[15:8]  = tr.data[15:8];
            if (tr.wstrb[2]) reg0[23:16] = tr.data[23:16];
            if (tr.wstrb[3]) reg0[31:24] = tr.data[31:24];
          end
          4'h4: begin
            if (tr.wstrb[0]) reg1[7:0]   = tr.data[7:0];
            if (tr.wstrb[1]) reg1[15:8]  = tr.data[15:8];
            if (tr.wstrb[2]) reg1[23:16] = tr.data[23:16];
            if (tr.wstrb[3]) reg1[31:24] = tr.data[31:24];
          end
          4'h8: begin
            if (tr.wstrb[0]) reg2[7:0]   = tr.data[7:0];
            if (tr.wstrb[1]) reg2[15:8]  = tr.data[15:8];
            if (tr.wstrb[2]) reg2[23:16] = tr.data[23:16];
            if (tr.wstrb[3]) reg2[31:24] = tr.data[31:24];
          end
          4'hC: begin
            if (tr.wstrb[0]) reg3[7:0]   = tr.data[7:0];
            if (tr.wstrb[1]) reg3[15:8]  = tr.data[15:8];
            if (tr.wstrb[2]) reg3[23:16] = tr.data[23:16];
            if (tr.wstrb[3]) reg3[31:24] = tr.data[31:24];
          end
          default: `uvm_warning("SB", $sformatf("WRITE to unknown addr = 0x%0h", tr.addr))
        endcase

        `uvm_info("SB", $sformatf("WRITE stored in scoreboard: %s", tr.convert2string()), UVM_MEDIUM)
      end
      else begin
        case (tr.addr)
          4'h0: expected_data = reg0;
          4'h4: expected_data = reg1;
          4'h8: expected_data = reg2;
          4'hC: expected_data = reg3;
          default: expected_data = 32'hDEAD_BEEF;
        endcase

        if (tr.rdata !== expected_data)
          `uvm_error("SB", $sformatf("READ MISMATCH addr=0x%0h expected=0x%08h actual=0x%08h",
                                     tr.addr, expected_data, tr.rdata))
        else
          `uvm_info("SB", $sformatf("READ MATCH addr=0x%0h data=0x%08h", tr.addr, tr.rdata), UVM_MEDIUM)
      end
    endfunction

  endclass


  class axi_agent extends uvm_agent;
    `uvm_component_utils(axi_agent)

    axi_sequencer seqr;
    axi_driver    drv;
    axi_monitor   mon;

    function new(string name = "axi_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      seqr = axi_sequencer::type_id::create("seqr", this);
      drv  = axi_driver   ::type_id::create("drv",  this);
      mon  = axi_monitor  ::type_id::create("mon",  this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

  endclass


  class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    axi_agent      agt;
    axi_scoreboard sb;

    function new(string name = "axi_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt = axi_agent      ::type_id::create("agt", this);
      sb  = axi_scoreboard ::type_id::create("sb",  this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.mon.mon_ap.connect(sb.sb_imp);
    endfunction

  endclass


  class axi_test extends uvm_test;
    `uvm_component_utils(axi_test)

    axi_env       env;
    axi_write_seq wr_seq;
    axi_read_seq  rd_seq;

    function new(string name = "axi_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = axi_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);

      phase.raise_objection(this);

      wr_seq = axi_write_seq::type_id::create("wr_seq");
      rd_seq = axi_read_seq ::type_id::create("rd_seq");

      wr_seq.start(env.agt.seqr);
      rd_seq.start(env.agt.seqr);

      #20;
      `uvm_info("TEST_DONE", "run phase is ready to proceed to the extract phase", UVM_LOW)

      phase.drop_objection(this);
    endtask

  endclass

endpackage