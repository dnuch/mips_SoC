`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2019 04:47:24 PM
// Design Name: 
// Module Name: and_2_1
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


module and_2_1 #(parameter w = 32)(
        input [w-1:0] in0, in1,
        output out
    );
    
    assign out = in0 & in1;
    
endmodule
