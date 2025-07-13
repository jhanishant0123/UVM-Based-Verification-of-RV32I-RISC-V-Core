SYSTEM VERILOG CODE FOR INSTRUCTION MEMORY :-

// ========================================================================
// Module: Instruction Memory
// Description: Read-only memory storing program instructions.
//              Loads contents from external hex/text file at start.
// Author: [NISHANT KUMAR JHA]
// Date: [29-06-2025]
// ========================================================================

module InstructionMemory #(
    parameter MEM_DEPTH = 256
)(
    input  logic [31:0] pc_address,           // Address from PC
    output logic [31:0] instr_out    // Fetched instruction
);

    // Memory array to hold instr_out
    logic [31:0] memory_array [0:MEM_DEPTH-1];

    // Initialize memory contents from external file
    initial begin
        $display("Loading Instruction Memory...");
        $readmemh("instr_out.mem", memory_array);
    end

    // Word-aligned addressing (ignore 2 LSBs)
    assign instr_out = memory_array[addr[9:2]];

endmodule
