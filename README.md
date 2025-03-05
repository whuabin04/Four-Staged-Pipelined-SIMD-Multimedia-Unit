# Project Source Code

This directory contains the source code for the Four-Staged Pipelined SIMD Multimedia Unit Design. Below is an overview of the key components and their functionality.

## Folder Structure

- **Assembler**
  - The assembler converts assembly instructions into machine code for execution within the pipeline.

- **Instruction Buffer Module**
  - Manages the flow of incoming instructions, buffering them to ensure smooth handoff between pipeline stages.

- **Register Module**
  - Implements the register file, handling read and write operations for data storage and retrieval during instruction execution.

- **ALU Stage with Testbench**
  - The Arithmetic Logic Unit (ALU) executes arithmetic and logical operations. This module includes a testbench for verifying the ALU's functionality.

- **Forwarding Unit**
  - Resolves data hazards by forwarding values between pipeline stages, ensuring correct instruction execution without unnecessary stalls.

- **Top-Level Structure with Testbench**
  - Integrates all pipeline components, orchestrating the overall execution flow. The testbench validates the complete system’s behavior through simulation.

## Usage

Each module is designed for standalone testing and integration within the top-level structure. The testbenches facilitate verification, ensuring module correctness before full system synthesis.