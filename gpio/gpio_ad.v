
module gpio_ad(
    input [1:0] a,
    input wire we,
    output wire we1,
    output wire we2,
    output [1:0] rd_sel
    );
    
assign we1 = (a[1] == 0)? 0 : we & (a[0]==0);
assign we2 = (a[1] == 0)? 0 : we & (a[0]==1);

assign rd_sel = a;

endmodule
