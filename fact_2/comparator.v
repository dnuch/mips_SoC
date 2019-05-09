`timescale 1ns / 1ps

module comparator_gt(a, b, gt);
input [3:0] a;
input [3:0] b;
output reg gt;

always @(a, b)
begin 
    gt = (a > b)? 1:0;
end

endmodule
