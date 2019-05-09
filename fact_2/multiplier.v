`timescale 1ns / 1ps
module multiplier(
    input wire [3:0] A,
    input wire [31:0] B,
    output wire [31:0] Y
    );
    
 assign Y = A*B;

endmodule

