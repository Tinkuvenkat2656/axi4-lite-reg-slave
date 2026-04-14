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

## UVM Testbench Progress

The AXI4-Lite UVM testbench has now been completed and simulated successfully in QuestaSim.

Completed components:
- transaction class
- write sequence
- read sequence
- sequencer
- driver
- monitor
- scoreboard
- agent
- environment
- test

The directed UVM testbench was compiled and simulated successfully. The simulation transcript confirms:
- successful write sequence execution
- successful read sequence execution
- monitor capture of transactions
- scoreboard update and read-data match
- zero UVM errors
- zero UVM fatals

Waveform and transcript screenshots were captured as proof of successful simulation.

A randomized/constrained version was also attempted, but it could not be simulated on the current system because the available QuestaSim license does not support the SystemVerilog verification feature required for randomization. Therefore, the current verified result in this project is based on the directed UVM testbench.

## Simulation Result

Simulation output showing successful write and read transactions is available in the `results/` folder.

The final simulation was completed successfully using the directed UVM testbench in QuestaSim.

### Result summary
- write transaction executed successfully
- read transaction returned the expected stored data
- monitor observed both write and read activity
- scoreboard reported correct read-data match
- UVM_ERROR = 0
- UVM_FATAL = 0

The waveform shows the AXI4-Lite signal timing and handshake behavior, and the transcript shows the successful execution log of the UVM testbench.
