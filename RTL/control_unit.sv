SYSTEM VERILOG CODE FOR MAIN CONTROL UNIT :-

// ========================================================================
// Module: Main Control Unit (for RISC-V)
// Description: Decodes opcode and generates control signals for pipeline.
// Author: [NISHANT KUMAR JHA]
// Date: [03-07-2025]
// ========================================================================

module ControlUnit (
  input  logic [6:0] opcode,             // 7-bit opcode from instruction  

    output logic       reg_write_en,       // Enables register write-back
    output logic       mem_read_en,        // Enables memory read
    output logic       mem_write_en,       // Enables memory write
    output logic       mem_to_reg,         // Selects MEM vs ALU for write-back
    output logic       alu_src_select,     // Chooses between register/immediate
    output logic       branch_en,          // Enables branch evaluation
    output logic [1:0] alu_op_control      // Encoded ALU operation
);

    always_comb begin
        // Default values (NOP)
        reg_write_en    = 0;
        mem_read_en     = 0;
        mem_write_en    = 0;
        mem_to_reg      = 0;
        alu_src_select  = 0;
        branch_en       = 0;
        alu_op_control  = 2'b00;

        case (opcode)
            7'b0110011: begin  // R-type
                reg_write_en    = 1;
                alu_src_select  = 0;
                alu_op_control  = 2'b10;
            end

            7'b0010011: begin  // I-type (addi, ori)
                reg_write_en    = 1;
                alu_src_select  = 1;
                alu_op_control  = 2'b11;
            end

            7'b0000011: begin  // Load (lw)
                reg_write_en    = 1;
                mem_read_en     = 1;
                mem_to_reg      = 1;
                alu_src_select  = 1;
                alu_op_control  = 2'b00;
            end

            7'b0100011: begin  // Store (sw)
                mem_write_en    = 1;
                alu_src_select  = 1;
                alu_op_control  = 2'b00;
            end

            7'b1100011: begin  // Branch (beq)
                branch_en       = 1;
                alu_op_control  = 2'b01;
            end

            default: begin
                // No operation (NOP or invalid instruction)
            end
        endcase

        // Debug statement for simulation
        $display("CTRL: OPCODE=%b | reg_write=%b mem_read=%b mem_write=%b alu_src=%b branch=%b alu_op=%b",
                  opcode, reg_write_en, mem_read_en, mem_write_en, alu_src_select, branch_en, alu_op_control);
    end

endmodule
