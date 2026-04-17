# AXI4-Lite Register Slave

This project was developed under the guidance of Linda Megerdichian as part of my learning in RTL Design and Design Verification.

## Overview

This design implements a simple AXI4-Lite Register Slave supporting basic read and write operations. The focus was on understanding the AXI4-Lite protocol and implementing correct handshake behavior between master and slave.

The design includes:
- AXI4-Lite compliant read and write channels  
- VALID/READY handshake implementation  
- Simple register storage model  

Rather than copying an existing implementation, I studied the AXI4-Lite protocol and built the design step by step based on my understanding. The logic was intentionally kept simple and clear to make debugging and verification easier.

## Design Goal

The primary goal of this design was to serve as a clean DUT for building a UVM-based verification environment. Keeping the RTL simple allows better focus on verification strategy without unnecessary complexity in the design.

---

## RTL Simulation

The design was compiled and simulated successfully using QuestaSim.

A basic sanity test was performed:
- one write transaction followed by one read transaction  
- read data matched the written data  

This confirms correct functionality for the basic use case.

Simulation output is available in the `results/` folder.

---

## UVM Testbench Development

The project was extended to include a UVM-based verification environment.

### Implemented Components
- transaction class  
- write and read sequences  
- sequencer  
- driver  
- monitor  
- scoreboard  
- agent  
- environment  
- test  

The UVM testbench was compiled and simulated successfully using a directed test.

### Verification Results
- write sequence executed successfully  
- read sequence returned expected data  
- monitor captured transactions correctly  
- scoreboard validated read data match  
- UVM_ERROR = 0  
- UVM_FATAL = 0  

Waveform and transcript outputs are included in the `results/` folder as proof of simulation.

---

## Limitation

A constrained-random version was attempted, but could not be simulated due to limitations of the available QuestaSim license (SystemVerilog verification features not supported).

Therefore, current verification results are based on directed testing.

---

## Simulation Result Summary

- successful write and read operations  
- correct AXI4-Lite handshake behavior  
- verified data integrity through scoreboard  
- clean simulation with no UVM errors or fatals  

---

## Next Steps

- Add constrained-random stimulus (when license permits)  
- Improve corner case coverage  
- Add assertions and functional coverage  
- Expand verification scenarios  

---

## Results

Simulation outputs (transcript and waveform) are available in the `results/` folder.

---

## Key Learnings

This project helped me move from writing RTL to understanding how designs are actually verified in practice.

Some of the key takeaways:

- Understanding AXI4-Lite handshake at a signal level (VALID/READY behavior) and how incorrect sequencing can break transactions  
- Realizing the importance of separating design logic (RTL) from verification logic (UVM)  
- Learning how drivers translate transactions into pin-level activity and how monitors reconstruct them back into transactions  
- Understanding the role of a scoreboard as a reference model rather than just a comparison block  
- Recognizing why simple DUT design helps in building and debugging a verification environment  
- Getting comfortable with the compile → simulate → debug cycle in QuestaSim  
- Seeing how even a basic directed test can validate functionality, but also its limitations compared to constrained-random testing  

This project shifted my focus from just “making the design work” to thinking in terms of “how to verify that it works under different scenarios.”
