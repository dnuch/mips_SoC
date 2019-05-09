`timescale 1ns / 1ps

module comparator(
    input [31:0] a,
    input [31:0] b,
    output wire out
    );
    
    assign out = (a == b)? 1:0;

endmodule
