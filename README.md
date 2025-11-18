# RISC-V Single-Cycle CPU (RV32I ISA)

## Overview
This project implements a single-cycle RISC-V processor (RV32I ISA) in Verilog HDL.  
The design includes a top-level wrapper, CPU core, instruction memory, and data memory.  
All 38 base RV32I instructions have been tested and verified with **ModelSim**.

## Project Structure
- **t1c_riscv_cpu.v**  
  Top-level wrapper module. Instantiates the CPU core, instruction memory, and data memory.  
  Provides external memory override signals for testing and initialization.

- **riscv_cpu.v**  
  The processor core. Combines the controller (instruction decoder) and datapath (register file, ALU, PC logic).  
  Executes instructions in a single cycle.

- **instr_mem.v**  
  Instruction memory (ROM). Word-aligned, initialized from a hex file (`rv32i_test.hex`).  
  Stores the program instructions fetched by the CPU.

- **data_mem.v**  
  Data memory (RAM). Supports byte, halfword, and word loads/stores with correct sign/zero extension.  
  Implements SB, SH, SW, LB, LH, LW, LBU, LHU.

## Features
- Implements the full RV32I base instruction set:
  - Arithmetic: ADD, SUB, ADDI
  - Logical: AND, OR, XOR, ANDI, ORI, XORI
  - Shifts: SLL, SRL, SRA, SLLI, SRLI, SRAI
  - Comparisons: SLT, SLTU, SLTI, SLTIU
  - Memory: LB, LH, LW, LBU, LHU, SB, SH, SW
  - Control flow: BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR
  - Upper immediates: LUI, AUIPC
- Verified with a comprehensive testbench (all instructions marked "implementation is correct").
- Clean modular design: controller, datapath, instruction memory, data memory.

## Verification
- Used ModelSim simulation with the provided testbench.
- All instructions tested and passed: **Faulty Instructions => 0**.
- Transcript shows: *No errors encountered, congratulations!*

## How to Run
1. Open the project in Quartus or your preferred Verilog simulator.
2. Ensure `rv32i_test.hex` (or your program file) is present in the project directory.
3. Compile and simulate `t1c_riscv_cpu.v`.
4. Observe outputs:
   - `PC`: Program counter
   - `Result`: ALU result
   - `MemWrite`, `DataAdr`, `WriteData`, `ReadData`: memory interface signals

## Notes
- Memory sizes in `data_mem.v` and `instr_mem.v` are fixed (64 words for data, 512 words for instructions).
- Minor Quartus warnings (implicit nets, memory file size mismatch) do not affect functionality.
- For robustness, ensure `.hex` files match declared memory depth.

---
