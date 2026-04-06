AXI4-Lite Register Slave

This project is developed under the guidance of Linda Megerdichian as part of my learning in Design Verification and RTL design.

The design is an AXI4-Lite register slave that supports basic read and write operations following the AXI4-Lite protocol. It implements the required handshake mechanism between master and slave and provides simple register storage functionality.

I did not copy this implementation directly. I went through AXI4-Lite documentation and references, understood how the protocol works, and then built the design step by step based on my understanding. While doing this, I made some design choices that keep the logic simple and easy to follow instead of making it overly complex.

The intention behind keeping this design simple is to use it as a starting point for building a UVM testbench. A clean and straightforward DUT makes it easier to write, debug, and validate the verification environment without unnecessary complications.

This design currently focuses on correctness and clarity. I will continue improving it by adding better handling of corner cases and developing a complete UVM-based verification environment around it.

Simulation Status

The design has been compiled and simulated successfully using QuestaSim after adding interface and top module along with DUT.

Sanity Stimulus has been added to Top and a basic write followed by a read transaction was performed from the top module. The read data matched the written data, confirming correct functionality for this scenario.

Simulation output is included in the "results/" folder as proof of execution.

## UVM Testbench Progress

As the next step in verification, I started building the initial UVM-based testbench for the AXI4-Lite register slave.

Completed so far:
- transaction class
- basic write sequence
- sequencer
- driver

The UVM package file (`tb/axi_uvm_pkg.sv`) was compiled successfully in QuestaSim with 0 errors and 0 warnings. Simulation output is included in the "results/" folder as proof of execution.

At this stage, the UVM components have been compiled and debugged up to the driver level. Full UVM simulation is the next step after adding the remaining components such as monitor, agent, environment, and test.

## Simulation Result

Simulation output showing successful write and read transactions is available in the `results/` folder.
