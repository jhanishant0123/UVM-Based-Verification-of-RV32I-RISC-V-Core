

SYSTEM VERILOG CODE FOR ALU :-

// ========================================================================
// Module: ALU (Custom Version)
// Description: Performs arithmetic and logical operations based on control signal.
//              Supports additional instructions like NOR and SRA.
//              Includes debug display for simulation.
// Author: [NISHANT KUMAR JHA]
// Date: [03-07-2025
// ========================================================================

module ALU (
    input  logic [31:0] operand1,         // First operand (typically from rs1)
    input  logic [31:0] operand2,         // Second operand (from rs2 or immediate)
    input  logic [3:0]  alu_control,      // ALU operation select signal
    output logic [31:0] alu_out,          // ALU output result
    output logic        zero_flag         // High when result is 0
);

    // ALU Operation (Combinational)
    always_comb begin
        case (alu_control)
            4'b0000: alu_out = operand1 + operand2;                    // ADD
            4'b0001: alu_out = operand1 - operand2;                    // SUB
            4'b0010: alu_out = operand1 & operand2;                    // AND
            4'b0011: alu_out = operand1 | operand2;                    // OR
            4'b0100: alu_out = operand1 ^ operand2;                    // XOR
            4'b0101: alu_out = operand1 << operand2[4:0];              // SLL (Logical Shift Left)
            4'b0110: alu_out = operand1 >> operand2[4:0];              // SRL (Logical Shift Right)
            4'b0111: alu_out = ($signed(operand1) < $signed(operand2)) ? 32'd1 : 32'd0; // SLT
            4'b1000: alu_out = ~(operand1 | operand2);                 // NOR
            4'b1001: alu_out = $signed(operand1) >>> operand2[4:0];    // SRA (Arithmetic Shift Right)
            default: alu_out = 32'd0;                                  // Default NOP (safe fallback)
        endcase

        // Optional simulation debug output
        $display("ALU Debug: operand1 = %h, operand2 = %h, ctrl = %b, result = %h",
                 operand1, operand2, alu_control, alu_out);
    end

    // Set zero flag if result is 0 (used by BEQ/BNE)
    assign zero_flag = (alu_out == 32'd0);

endmodule
