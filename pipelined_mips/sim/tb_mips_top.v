module tb_mips_top;

    reg         clk;
    reg         rst;
    wire        we_dm;
    wire [31:0] pc_current;
    wire [31:0] instr;
    wire [31:0] alu_out;
    wire [31:0] wd_dm;
    wire [31:0] rd_dm;
    wire [31:0] DONT_USE;
    
    reg [31:0]  gpi_1, gpi_2;
    wire [31:0] gpo_1, gpo_2;
    
    mips_top DUT (
            .clk            (clk),
            .rst            (rst),
            .gpi_1          (gpi_1),
            .gpi_2          (gpi_2),
            .we             (we_dm),
            .ra3            (5'h0),
            .pc_current     (pc_current),
            .instr          (instr),
            .alu_out        (alu_out),
            .wd             (wd_dm),
            .ReadData       (rd_dm),
            .rd3            (DONT_USE),
            .gpo_1          (gpo_1),
            .gpo_2          (gpo_2)
        );
    
    task tick; 
    begin 
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end
    endtask

    task reset;
    begin 
        rst = 1'b0; #5;
        rst = 1'b1; #5;
        rst = 1'b0;
    end
    endtask
    
    initial begin
    
        reset;
        gpi_2 = 0;
        for (integer i = 0; i < 16; i = i + 1) begin
            gpi_1 = i;
            
            while(pc_current != 32'h6C) tick;
            tick;
        end
        $finish;
    end

endmodule
