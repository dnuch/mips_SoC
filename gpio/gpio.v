`timescale 1ns / 1ps


module gpio(
    input clk,
    input rst,
    input [1:0] A,
    input we,
    input [31:0] gpi_1, 
    input [31:0] gpi_2,
    input [31:0] wd,
    output [31:0] rd,
    output [31:0] gpo_1,
    output [31:0] gpo_2   
    );
    
    wire gpo1_sel, gpo2_sel;
    wire [1:0] rd_sel;
    
    dreg_en gpo1_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (wd),
                .q              (gpo_1),
                .en             (gpo1_sel)
            ); 
            
    dreg_en gpo2_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (wd),
                .q              (gpo_2),
                .en             (gpo2_sel)
            );       

    mux4 #32 r_mux (
                .a              (gpi_1),
                .b              (gpi_2),
                .c              (gpo_1),
                .d              (gpo_2),
                .sel            (rd_sel),
                .y              (rd)                
            );

    gpio_ad decoder(
                .a      (A),
                .we     (we),
                .we1    (gpo1_sel),
                .we2    (gpo2_sel),
                .rd_sel (rd_sel)
           );
           
           
endmodule

