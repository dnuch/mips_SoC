`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2019 02:05:03 PM
// Design Name: 
// Module Name: mux_4_1
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


module mux_4_1 #(parameter w = 32) (
        input [1:0] sel,
        input [w-1:0] in1, in2, in3, in4,
        output reg [w-1:0] out
    );
    
    always @ (*) begin
        case (sel)
            2'b00: out = in1;
            2'b01: out = in2;
            2'b10: out = in3;
            2'b11: out = in4;
            default: out = 0;
        endcase
    end
    
endmodule
