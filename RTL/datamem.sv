SYSTEM VERILOG CODE FOR DATA MEMORY MODULE :-


// ========================================================================
// Module: Data Memory (MEM Stage)
// Description: Performs memory reads and writes for lw/sw instructions.
// Author: [NISHANT KUMAR JHA]
// Date: [03-07-2025]
// ========================================================================

module DataMemory #(
    parameter MEM_SIZE = 256  // Number of 32-bit words
)(
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,

    output logic [31:0] read_data
);

    // Define memory array
    logic [31:0] memory_array [0:MEM_SIZE-1];

    // Read (asynchronous)
    always_comb begin
        if (mem_read)
            read_data = memory_array[address[31:2]]; // word-aligned
        else
            read_data = 32'd0;
    end

    // Write (synchronous)
    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory_array[address[31:2]] <= write_data;

            // Debug message for write
            $display("MEM: Writing %h to MEM[%0d]", write_data, address[31:2]);
        end
    end

endmodule
