AXI4-Lite Register Slave

This project is developed under the guidance of Linda Megerdichian as part of my learning in Design Verification and RTL design.

The design is an AXI4-Lite register slave that supports basic read and write operations following the AXI4-Lite protocol. It implements the required handshake mechanism between master and slave and provides simple register storage functionality.

I did not copy this implementation directly. I went through AXI4-Lite documentation and references, understood how the protocol works, and then built the design step by step based on my understanding. While doing this, I made some design choices that keep the logic simple and easy to follow instead of making it overly complex.

The intention behind keeping this design simple is to use it as a starting point for building a UVM testbench. A clean and straightforward DUT makes it easier to write, debug, and validate the verification environment without unnecessary complications.

This design currently focuses on correctness and clarity. I will continue improving it by adding better handling of corner cases and developing a complete UVM-based verification environment around it.
