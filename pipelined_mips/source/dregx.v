module dregNOOP # (parameter WIDTH = 32) (
        input  wire             clk,
        input  wire             rst,
        input  wire [WIDTH-1:0] d,
        output reg  [WIDTH-1:0] q
    );
    always @ (posedge clk, posedge rst) begin
        if (rst) q <= {WIDTH{1'b1}} ;
        else     q <= d;
    end
endmodule
