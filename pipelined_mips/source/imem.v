module imem (
        input  wire [5:0]  a,
        output wire [31:0] y
    );

    reg [31:0] rom [0:63];

    initial begin
        $readmemh ("C:/Users/drnuc/OneDrive/Desktop/mips_SoC_pipelined_hazards/pipelined_mips/fact_test.dat", rom);
    end

    assign y = rom[a];
    
endmodule