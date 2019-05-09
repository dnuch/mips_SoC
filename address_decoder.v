`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2019 07:52:42 PM
// Design Name: 
// Module Name: address_decoder
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


module address_decoder(
        input WE,
        input [31:0] A,
        output wire WE1, WE2, WEM,
        output wire [1:0] RdSel
    );
    
    // WE1, WE2, WEM, RdSel
    reg [4:0] ctrl_signals;
    
    always @ (*) begin
        case (A[8:4])
            // select fact. accelerator
            5'b1_0000: ctrl_signals = WE ? 5'b1_0_0_10 : 5'b0_0_0_10;
            // select gpio
            5'b1_0010: ctrl_signals = WE ? 5'b0_1_0_11 : 5'b0_0_0_11;
            // select data memory
            default:   ctrl_signals = (A[8:4]   >= 5'b0_0000 
                                      && A[8:4] < 5'b1_0000 
                                      && WE) ? 5'b0_0_1_00 : 5'b0_0_0_00;
        endcase
    end
    
    assign {WE1, WE2, WEM, RdSel} = ctrl_signals;
    
endmodule
