SYSTEM VERILOG CODE FOR REGISTER :-

// ========================================================================
// Module: Register File (Custom Version)
// Description: Parameterized 32-register file with dual-read and single-write
//              Register x0 is fixed to zero (RISC-V compliance).
//              Includes simulation debug message on write.
// Author: [NISHANT KUMAR JHA]
// Date: [03-07-2025]
// ========================================================================

module RegisterFile #(
    parameter REG_WIDTH = 32,             // Width of each register
    parameter REG_COUNT = 32              // Number of registers
)(
    input  logic                     clk,                 // Clock signal
    input  logic                     reg_write_enable,    // Write enable signal
    input  logic [4:0]               read_reg1,           // Address of first register to read
    input  logic [4:0]               read_reg2,           // Address of second register to read
    input  logic [4:0]               write_reg,           // Address of register to write
    input  logic [REG_WIDTH-1:0]     write_back_data,     // Data to be written
    output logic [REG_WIDTH-1:0]     read_data_1,         // Output data from read_reg1
    output logic [REG_WIDTH-1:0]     read_data_2          // Output data from read_reg2
);

    // Internal register array
    logic [REG_WIDTH-1:0] reg_file [0:REG_COUNT-1];

    // Combinational read logic
    assign read_data_1 = (read_reg1 == 5'd0) ? '0 : reg_file[read_reg1];
    assign read_data_2 = (read_reg2 == 5'd0) ? '0 : reg_file[read_reg2];

    // Sequential write logic
    always_ff @(posedge clk) begin
        if (reg_write_enable && (write_reg != 5'd0)) begin
            reg_file[write_reg] <= write_back_data;

            // Debug: Print which register was written
            $display("Register Write: x%0d <= %h", write_reg, write_back_data);
        end
    end

endmodule
