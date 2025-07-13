// ========================================================================
// Top-level Module: RISC-V 5-Stage Pipelined Processor
// Author: [NISHANT KUMAR JHA]
// Description: Connects all pipeline stages and registers
// ========================================================================

module top (
    input logic clk,
    input logic rst
);

    // -----------------------------------------------
    // 1. IF Stage (Program Counter + Instruction Memory)
    // -----------------------------------------------
    logic [31:0] pc, next_pc;
    logic [31:0] instruction;

    PC pc_module (
        .clk(clk),
        .rst(rst),
        .pc_in(next_pc),
        .pc_out(pc)
    );

    InstructionMemory instr_mem (
        .addr(pc),
        .instruction(instruction)
    );

    // -----------------------------------------------
    // IF/ID Pipeline Register
    // -----------------------------------------------
    logic [31:0] ifid_pc_out, ifid_inst_out;

    IF_ID if_id_reg (
        .clk(clk),
        .rst(rst),
        .pc_in(pc),
        .instruction_in(instruction),
        .pc_out(ifid_pc_out),
        .instruction_out(ifid_inst_out)
    );

    // -----------------------------------------------
    // 2. ID Stage (Control, Register File, ImmGen)
    // -----------------------------------------------
    logic [6:0] opcode = ifid_inst_out[6:0];
    logic [2:0] funct3 = ifid_inst_out[14:12];
    logic       funct7_bit = ifid_inst_out[30];

    logic [4:0] rs1 = ifid_inst_out[19:15];
    logic [4:0] rs2 = ifid_inst_out[24:20];
    logic [4:0] rd  = ifid_inst_out[11:7];

    logic [31:0] reg_data1, reg_data2;
    logic [31:0] imm_data;

    logic        reg_write_en, mem_read_en, mem_write_en, alu_src_select, mem_to_reg, branch;
    logic [1:0]  alu_op;

    ControlUnit control (
        .opcode(opcode),
        .reg_write_en(reg_write_en),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .mem_to_reg(mem_to_reg),
        .alu_src_select(alu_src_select),
        .branch_en(branch),
        .alu_op_control(alu_op)
    );

    RegisterFile reg_file (
        .clk(clk),
        .rst(rst),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd_wb),         // From WB stage
        .write_data(write_back_data),
        .reg_write(reg_write_wb),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    ImmGen immgen (
        .instruction(ifid_inst_out),
        .imm_out(imm_data)
    );

    // -----------------------------------------------
    // ID/EX Pipeline Register
    // -----------------------------------------------
    logic [31:0] idex_pc_out, idex_imm_out, idex_reg1_out, idex_reg2_out;
    logic [4:0]  idex_rd_out;
    logic        idex_reg_write, idex_mem_read, idex_mem_write, idex_mem_to_reg, idex_alu_src;
    logic [1:0]  idex_alu_op;

    ID_EX id_ex_reg (
        .clk(clk),
        .rst(rst),
        .src_data_a_in(reg_data1),
        .src_data_b_in(reg_data2),
        .imm_value_in(imm_data),
        .dest_reg_in(rd),
        .pc_input(ifid_pc_out),
        .ex_control_in(alu_op),
        .reg_write_en_in(reg_write_en),
        .mem_write_en_in(mem_write_en),
        .memory_enable_in(mem_read_en),
        .src_data_a_out(idex_reg1_out),
        .src_data_b_out(idex_reg2_out),
        .imm_value_out(idex_imm_out),
        .dest_reg_out(idex_rd_out),
        .pc_out(idex_pc_out),
        .ex_control_out(idex_alu_op),
        .reg_write_en_out(idex_reg_write),
        .mem_write_en_out(idex_mem_write),
        .memory_enable_out(idex_mem_read)
    );

    // -----------------------------------------------
    // 3. EX Stage (ALU + ALUControl)
    // -----------------------------------------------
    logic [3:0] alu_control_signal;
    logic [31:0] alu_operand_b, alu_result;

    ALUControl alu_ctrl (
        .alu_op(idex_alu_op),
        .funct3(funct3),
        .funct7_bit(funct7_bit),
        .alu_ctrl(alu_control_signal)
    );

    assign alu_operand_b = idex_alu_src ? idex_imm_out : idex_reg2_out;

    ALU alu_unit (
        .operand1(idex_reg1_out),
        .operand2(alu_operand_b),
        .alu_control(alu_control_signal),
        .alu_out(alu_result)
    );

    // -----------------------------------------------
    // EX/MEM Pipeline Register
    // -----------------------------------------------
    logic [31:0] exmem_alu_result, exmem_store_data;
    logic [4:0]  exmem_rd;
    logic        exmem_reg_write, exmem_mem_read, exmem_mem_write, exmem_mem_to_reg;

    EX_MEM ex_mem_reg (
        .clk(clk),
        .rst(rst),
        .alu_out_in(alu_result),
        .store_data_in(idex_reg2_out),
        .rd_ex_in(idex_rd_out),
        .reg_write_ex_in(idex_reg_write),
        .mem_read_ex_in(idex_mem_read),
        .mem_write_ex_in(idex_mem_write),
        .mem_to_reg_ex_in(idex_mem_to_reg),
        .alu_out_exmem(exmem_alu_result),
        .store_data_exmem(exmem_store_data),
        .rd_exmem(exmem_rd),
        .reg_write_exmem(exmem_reg_write),
        .mem_read_exmem(exmem_mem_read),
        .mem_write_exmem(exmem_mem_write),
        .mem_to_reg_exmem(exmem_mem_to_reg)
    );

    // -----------------------------------------------
    // 4. MEM Stage (Data Memory)
    // -----------------------------------------------
    logic [31:0] mem_data_out;

    DataMemory data_mem (
        .clk(clk),
        .mem_read(exmem_mem_read),
        .mem_write(exmem_mem_write),
        .address(exmem_alu_result),
        .write_data(exmem_store_data),
        .read_data(mem_data_out)
    );

    // -----------------------------------------------
    // MEM/WB Pipeline Register
    // -----------------------------------------------
    logic [31:0] wb_mem_data, wb_alu_result;
    logic [4:0]  wb_rd;
    logic        reg_write_wb, mem_to_reg_wb;

    MEM_WB mem_wb_reg (
        .clk(clk),
        .rst(rst),
        .mem_data_in(mem_data_out),
        .alu_result_in(exmem_alu_result),
        .dest_reg_in(exmem_rd),
        .reg_write_en_in(exmem_reg_write),
        .mem_to_reg_in(exmem_mem_to_reg),
        .mem_data_out(wb_mem_data),
        .alu_result_out(wb_alu_result),
        .dest_reg_out(wb_rd),
        .reg_write_en_out(reg_write_wb),
        .mem_to_reg_out(mem_to_reg_wb)
    );

    // -----------------------------------------------
    // 5. WB Stage (Register Write-back)
    // -----------------------------------------------
    logic [31:0] write_back_data;
    assign write_back_data = mem_to_reg_wb ? wb_mem_data : wb_alu_result;

    assign rd_wb = wb_rd;

    // -----------------------------------------------
    // PC Update Logic (Simple PC+4 for now)
    // -----------------------------------------------
    assign next_pc = pc + 4;

endmodule
