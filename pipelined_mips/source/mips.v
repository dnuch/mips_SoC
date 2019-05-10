module mips (
        input  wire        clk,
        input  wire        rst,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire        we_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3
    );
    
    wire       branch;
    wire       jump;
    wire       reg_dst;
    wire       we_reg;
    wire       alu_src;
    wire       dm2reg;
    wire [3:0] alu_ctrl;
    wire        jal;
    wire        jr;
    wire        shmux;
    wire        mult_enable;
    wire        sfmux_high;
    wire        sf2reg;
    wire [31:0] instrD;

    // Internal Signals needed for Hazard Unit
    wire StallF;
    wire StallD;
    wire FlushE;
    wire fordAD;
    wire fordBD;
    wire [1:0] fordAE;
    wire [1:0] fordBE;
    wire fordMultM;
    wire [4:0]  rf_waE;
    wire [4:0]  rf_waM;
    wire [4:0]  rf_waW;        
    wire [31:0] instrE;
    wire we_regE;
    wire we_regM;
    wire we_regW;
    wire sf2regM;
    wire dm2regE;
    wire dm2regM;
    
    datapath dp (
            .clk            (clk),
            .rst            (rst),
            .branch         (branch),
            .jump           (jump),
            .reg_dst        (reg_dst),
            .we_reg         (we_reg),
            .alu_src        (alu_src),
            .dm2reg         (dm2reg),
            .alu_ctrl       (alu_ctrl),
            .ra3            (ra3),
            .instr          (instr),
            .rd_dm          (rd_dm),
            .pc_current     (pc_current),
            .alu_out        (alu_out),
            .wd_dm          (wd_dm),
            .rd3            (rd3),
            .jal             (jal),
            .jr             (jr),
            .shmux          (shmux),
            .mult_enable    (mult_enable),
            .sfmux_high     (sfmux_high),
            .sf2reg         (sf2reg),
            .instrD         (instrD),
            // Additional signals for Hazard Unit
            // ___inputs from Hazard Unit___
            .StallF         (StallF),
            .StallD         (StallD),
            .FlushE         (FlushE),
            .fordAD         (fordAD),
            .fordBD         (fordBD),
            .fordAE         (fordAE),
            .fordBE         (fordBE),
            .fordMultM      (fordMultM),
            // ___outputs to Hazard Unit___
            .rf_wa_rdtE     (rf_waE),
            .rf_wa_rdtM     (rf_waM),
            .rf_wa_rdtW     (rf_waW),
            // need these two so that Hazard Unit can sample rs and rt (just being lazy) 
            .instrE         (instrE)        
        );

    controlunit cu (
            .clk            (clk),
            .rst            (rst),
            .opcode         (instrD[31:26]),
            .funct          (instrD[5:0]),
            .branch         (branch),
            .jump           (jump),
            .reg_dst        (reg_dst),
            .we_reg         (we_reg),
            .alu_src        (alu_src),
            .we_dm          (we_dm),
            .dm2reg         (dm2reg),
            .alu_ctrl       (alu_ctrl),
            .jal             (jal),
            .jr             (jr),
            .shmux          (shmux),
            .mult_enable    (mult_enable),
            .sfmux_high     (sfmux_high),
            .sf2reg         (sf2reg),
            // Control Signals sampled by Hazard Unit
            .we_regE        (we_regE),
            .we_regM        (we_regM),
            .we_regW        (we_regW),
            .sf2regM        (sf2regM),
            .dm2regE        (dm2regE),
            .dm2regM        (dm2regM),
            // Input from Hazard Unit to Flush E-Reg
            .FlushE         (FlushE)
        );
        
    hazard_unit hu(
                // Inputs from datapath
            .rsD            (instrD[25:21]),
            .rtD            (instrD[20:16]),
            .rsE            (instrE[25:21]),
            .rtE            (instrE[20:16]),
            .rf_waE         (rf_waE),
            .rf_waM         (rf_waM),
            .rf_waW         (rf_waW),
                // Inputs from control unit
            .we_regE        (we_regE),
            .we_regM        (we_regM),
            .we_regW        (we_regW),
            .sf2regM        (sf2regM),
            .dm2regE        (dm2regE), 
            .dm2regM        (dm2regM), 
            .branchD        (branch), // branch is already in D-stage
                // Output
            .StallF         (StallF),
            .StallD         (StallD),
            .FlushE         (FlushE),
            .fordAD         (fordAD),
            .fordBD         (fordBD),
            .fordAE         (fordAE),
            .fordBE         (fordBE),
            .fordMultM      (fordMultM)
        );

endmodule