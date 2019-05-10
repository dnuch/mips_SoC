module multiplier_en(
    input wire [31:0]  A,
    input wire [31:0]  B,
    input wire         en,
    output reg [63:0] Y = 0
    );

always @ (A, B, en)
begin
    if (en) Y <= A * B;
    else    Y <= Y;
end    
    
endmodule
