module mux4 #(parameter WIDTH = 32) (
        input  wire [1:0]       sel,
        input  wire [WIDTH-1:0] a,
        input  wire [WIDTH-1:0] b, 
        input  wire [WIDTH-1:0] c,
        input  wire [WIDTH-1:0] d, 
        output reg [WIDTH-1:0] y
    );
    
    always @ (*)
    begin
    case(sel)
        2'b00: y = a;
        2'b01: y = b;
        2'b10: y = c;
        default: y = d;
    endcase
    end
    
endmodule
