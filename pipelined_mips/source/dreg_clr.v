`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2019 10:13:36 AM
// Design Name: 
// Module Name: dreg_enx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module dreg_clr # (parameter WIDTH = 32) (
        input  wire             clk,
        input  wire             rst,
        input  wire             clr,
        input  wire [WIDTH-1:0] d,
        output reg  [WIDTH-1:0] q
    );

    always @ (posedge clk, posedge rst) begin
        if (rst)        q <= 0;
        else if (clr)   q <= 0;
        else            q <= d;
    end
endmodule

