
interface riscv_if(input bit clk);
    logic rst;
    
    logic [31:0] instr_addr;
    logic [31:0] instr_data;
    
    logic [31:0] data_addr;
    logic [31:0] data_wr_data;
    logic [31:0] data_rd_data;
    
    logic mem_wr_en;
    logic mem_rd_en;
    
    modport DUT (
        input clk, rst,
        output instr_addr,
        input instr_data,
        output data_addr, data_wr_data,
        input data_rd_data,
        output mem_wr_en, mem_rd_en
    );
    
    modport DRV (
        input clk,
        output rst,
        output instr_data, data_rd_data,
        input instr_addr, data_addr, data_wr_data,
        output mem_wr_en, mem_rd_en
    );
    
    modport MON (
        input clk,
        input rst,
        input instr_addr, instr_data,
        input data_addr, data_wr_data, data_rd_data,
        input mem_wr_en, mem_rd_en
    );
endinterface

