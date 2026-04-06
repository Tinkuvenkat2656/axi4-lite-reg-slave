package axi_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum {OP_WRITE, OP_READ} axi_op_t;

  class axi_txn extends uvm_sequence_item;
    `uvm_object_utils(axi_txn)

    rand axi_op_t    op;
    rand bit [3:0]   addr;
    rand bit [31:0]  data;
    rand bit [3:0]   wstrb;

    bit [31:0]       rdata;
    bit [1:0]        resp;

    constraint valid_addr {
      addr inside {4'h0, 4'h4, 4'h8, 4'hC};
    }

    constraint valid_wstrb {
      if (op == OP_WRITE)
        wstrb != 0;
    }

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
      assert(tr.randomize() with {
        op == OP_WRITE;
        wstrb == 4'hF;
      });
      `uvm_info("WRITE_SEQ", tr.convert2string(), UVM_MEDIUM)
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

    virtual axi_if vif;

    function new(string name = "axi_driver", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
        `uvm_fatal("DRV", "virtual interface not set for axi_driver")
    endfunction

    task run_phase(uvm_phase phase);
      axi_txn tr;

      set_defaults();

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
      vif.BREADY  <= 1;

      wait (vif.AWREADY && vif.WREADY);

      @(posedge vif.ACLK);
      vif.AWVALID <= 0;
      vif.WVALID  <= 0;

      wait (vif.BVALID);
      tr.resp = vif.BRESP;

      @(posedge vif.ACLK);
      vif.BREADY <= 0;
    endtask

    task drive_read(axi_txn tr);
      @(posedge vif.ACLK);

      vif.ARADDR  <= tr.addr;
      vif.ARVALID <= 1;
      vif.RREADY  <= 1;

      wait (vif.ARREADY);

      @(posedge vif.ACLK);
      vif.ARVALID <= 0;

      wait (vif.RVALID);
      tr.rdata = vif.RDATA;
      tr.resp  = vif.RRESP;

      @(posedge vif.ACLK);
      vif.RREADY <= 0;
    endtask

  endclass

endpackage