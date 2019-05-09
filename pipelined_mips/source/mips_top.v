module mips_top (
        input  wire        clk,
        input  wire        rst,
        input  wire [4:0]  ra3,
        input  wire [31:0] gpi_1,
        input  wire [31:0] gpi_2,
        output wire        we,
        output wire [31:0] pc_current,
        output wire [31:0] instr,
        output wire [31:0] alu_out,
        output wire [31:0] wd,
        output wire [31:0] ReadData,
        output wire [31:0] rd3,
        output wire [31:0] gpo_1,
        output wire [31:0] gpo_2
    );

    wire [31:0] DONT_USE, DMemData, FactData, GPIOData;
    wire WE1, WE2, WEM;
    wire [1:0] RdSel;
		
	mips mips (
			.clk            (clk),
			.rst            (rst),
			.ra3            (ra3),
			.instr          (instr),
			.rd_dm          (ReadData),
			.we_dm          (we),
			.pc_current     (pc_current),
			.alu_out        (alu_out),
			.wd_dm          (wd),
			.rd3            (rd3)
		);

    imem imem (
            .a              (pc_current[7:2]),
            .y              (instr)
        );

	address_decoder addr_decoder(
			 .WE(we),
			 .A(alu_out),
			 .WE1(WE1),
			 .WE2(WE2), 
			 .WEM(WEM),
			 .RdSel(RdSel)
		);
		
    dmem dmem (
            .clk            (clk),
            .we             (WEM),
            .a              (alu_out[7:2]),
            .d              (wd),
            .q              (DMemData)
        );
		
	factorial_interface fact(
			.A(alu_out[3:2]),
			.WE(WE1), 
			.rst(rst), 
			.clk(clk),
			.WD(wd),
			.RD(FactData)
		);
    
    gpio gpio(
			.clk(clk),
			.rst(rst),
			.A(alu_out[3:2]),
			.we(WE2),
			.gpi_1(gpi_1), 
			.gpi_2(gpi_2),
			.wd(wd),
			.rd(GPIOData),
			.gpo_1(gpo_1),
			.gpo_2(gpo_2) 
		);
    
    mux_4_1 mux_4_1(
			.sel(RdSel),
			.in1(DMemData), 
			.in2(DMemData),
			.in3(FactData), 
			.in4(GPIOData),
			.out(ReadData)
		);

endmodule