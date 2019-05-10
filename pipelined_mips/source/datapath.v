module datapath (
        input  wire        clk,
        input  wire        rst,
        input  wire        branch,
        input  wire        jump,
        input  wire        jal,
        input  wire        jr,
        input  wire        shmux,
        input  wire        reg_dst,
        input  wire        we_reg,
        input  wire        alu_src,
        input  wire        dm2reg,
        input  wire        mult_enable,
        input  wire        sfmux_high,
        input  wire        sf2reg,
        input  wire [3:0]  alu_ctrl,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        
        // ___inputs from Hazard Unit___
        input wire StallF,
        input wire StallD,
        input wire FlushE,
        input wire fordAD,
        input wire fordBD,
        input wire [1:0] fordAE,
        input wire [1:0] fordBE,
        input wire fordMultM,
        // ___outputs to Hazard Unit___
        output wire [4:0]  rf_wa_rdtE,
        output wire [4:0]  rf_wa_rdtM,
        output wire [4:0]  rf_wa_rdtW,        
        //______________________________

        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3,
        
        // need these two so that Hazard Unit can sample rs and rt (just being lazy) 
        output wire [31:0] instrD,
        output wire [31:0] instrE

    );
    
    wire [31:0] rd_dmM;
    wire [31:0] alu_outM;
    wire [31:0] wd_dmM;
    assign rd_dmM = rd_dm;
    assign alu_out = alu_outM;
    assign wd_dm = wd_dmM;
    
    wire [31:0]  instrM;
    wire [31:0]  instrW;
    wire [31:0] pc_plus4D;
    wire [31:0]  shamt_in;
    wire [4:0]  rf_wa;
    wire [4:0]  rf_wa_ra;
    wire        pc_src;
    wire [31:0] rd_dmW;
    wire [31:0] pc_plus4F;    
    wire [31:0] pc_plus8;    
    wire [31:0] pc_pre;
    wire [31:0] pc_next;
    wire [31:0] pc_next_pre;
    wire [31:0] sext_immD;
    wire [31:0] sext_immE;
    wire [31:0] ba;
    wire [31:0] bta;
    wire [31:0] jta;
    wire [31:0] alu_pa;
    wire [31:0] alu_pb;
    wire [31:0] wd_rf;
    wire [31:0] high_inE;
    wire [31:0] low_inE;
    wire [31:0] high_inM;
    wire [31:0] low_inM;
//    wire [31:0] high_inW;
//    wire [31:0] low_inW;
    wire [31:0] alu_outE;
    wire [31:0] alu_outW;
    wire [31:0] sfmux_in0;
    wire [31:0] sfmux_in1;
    wire [31:0] sfmux_outM;
    wire [31:0] sfmux_outW;
    wire [31:0] fordOutM;
    wire [31:0] ford_rsE;
    wire [31:0] ford_rtE;
    wire [31:0] wd_aludm;
    wire [31:0] wd_sfhl;    
    wire [31:0] rsD;
    wire [31:0] rsE;
    wire [31:0] wd_dmD;
    wire [31:0] wd_dmE;
    wire        zero;
    
    assign pc_src = branch & zero;
    assign ba = {sext_immD[29:0], 2'b00};
    assign jta = {pc_plus4F[31:28], instrD[25:0], 2'b00};
    assign shamt_in = {27'd0, instrE[10:6]};
    
    // HAZARD HANDLER COMPONENTS
    //____ BEQ Hazard _____ (Decode)
    wire [31:0] cmpA;
    wire [31:0] cmpB;
        
    comparator comp(
            .a              (cmpA),
            .b              (cmpB),
            .out            (zero)
            );
                
    mux2 #(32) rsD_mux (
            .sel            (fordAD),
            .a              (rsD),
            .b              (fordOutM), 
            .y              (cmpA)
            );
    
    mux2 #(32) rtD_mux (
            .sel            (fordBD),
            .a              (wd_dmD),
            .b              (fordOutM), 
            .y              (cmpB)
            );
    
    //____ ALU & MULT Operation Hazard _____ (Execution)
    mux4 #32 rsE_mux (
                    .a              (rsE),
                    .b              (wd_sfhl),
                    .c              (fordOutM),
                    .d              (rsE), // Should never be used, set to rsE just for precaution
                    .sel            (fordAE),
                    .y              (ford_rsE)                
                );
                
    mux4 #32 rtE_mux (
                    .a              (wd_dmE),
                    .b              (wd_sfhl),
                    .c              (fordOutM),
                    .d              (wd_dmE), // Should never be used, set to wd_dmE just for precaution
                    .sel            (fordBE),
                    .y              (ford_rtE)                
                            );
    mux2 #32 alumult_mux (
                    .sel            (fordMultM),
                    .a              (alu_outM),
                    .b              (sfmux_outM), 
                    .y              (fordOutM)
                );                


    // ________________________________
    
    
    // Stage Registers       
    // ---DECODE---
    dreg_enx InstrD_reg (
                .clk            (clk),
                .rst            (rst),
                .enx            (StallD),
                .d              (instr),
                .q              (instrD)
            );
   
   dreg_enx pcplus4D_reg (
                .clk            (clk),
                .rst            (rst),
                .enx            (StallD),
                .d              (pc_plus4F),
                .q              (pc_plus4D)
            );
    // ---EXECUTE---
    dreg_clr InstrE_reg (
                .clk            (clk),
                .rst            (rst),
                .clr            (FlushE),
                .d              (instrD),
                .q              (instrE)
            );
    
    dreg_clr rsE_reg (
                .clk            (clk),
                .rst            (rst),
                .clr            (FlushE),
                .d              (rsD),
                .q              (rsE)
            );
            
    dreg_clr wd_dmE_reg (
                .clk            (clk),
                .rst            (rst),
                .clr            (FlushE),
                .d              (wd_dmD),
                .q              (wd_dmE)
            );

    dreg_clr sext_immE_reg (
                .clk            (clk),
                .rst            (rst),
                .clr            (FlushE),
                .d              (sext_immD),
                .q              (sext_immE)
            );
    // ---MEMORY---
    dreg InstrM_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (instrE),
                .q              (instrM)
            );
                
    dreg #64 multM_reg (
                .clk            (clk),
                .rst            (rst),
                .d              ({high_inE, low_inE}),
                .q              ({high_inM, low_inM})
    );

    dreg aluM_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (alu_outE),
                .q              (alu_outM)
    );        
    
    dreg wd_dmM_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (wd_dmE),
                .q              (wd_dmM)
    );

    dreg #5 rfwa_rdtM_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (rf_wa_rdtE),
                .q              (rf_wa_rdtM)
    );            
    
    //---WRITE-BACK---
    dreg InstrW_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (instrM),
                .q              (instrW)
            );
    
    dreg SFmuxW_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (sfmux_outM),
                .q              (sfmux_outW)
            );    
//    dreg #64 multW_reg (
//                .clk            (clk),
//                .rst            (rst),
//                .d              ({high_inM, low_inM}),
//                .q              ({high_inW, low_inW})
//    );

    dreg rd_dmW_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (rd_dmM),
                .q              (rd_dmW)
    );
    
    dreg aluW_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (alu_outM),
                .q              (alu_outW)
    );    
    
    dreg #5 rfwa_rdtW_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (rf_wa_rdtM),
                .q              (rf_wa_rdtW)
    );    
    
    
    // --- PC Logic --- //
    dreg_enx pc_reg (
            .clk            (clk),
            .rst            (rst),
            .enx            (StallF),
            .d              (pc_next),
            .q              (pc_current)
        );

    adder pc_plus_4 (
            .a              (pc_current),
            .b              (32'd4),
            .y              (pc_plus4F)
        );

    adder plus_4 (
            .a              (pc_plus4D),
            .b              (32'd4),
            .y              (pc_plus8)
        );
        
    adder pc_plus_br (
            .a              (pc_plus4D),
            .b              (ba),
            .y              (bta)
        );

    mux2 #(32) pc_src_mux (
            .sel            (pc_src),
            .a              (pc_plus4F),
            .b              (bta),
            .y              (pc_pre)
        );

    mux2 #(32) pc_jmp_mux (
            .sel            (jump),
            .a              (pc_pre),
            .b              (jta),
            .y              (pc_next_pre)
        );
        
    // --- jal & jr Support --- //
    mux2 #(32) rfwd_jal_mux (
                .sel            (jal),
                .a              (wd_sfhl),
                .b              (pc_plus8),
                .y              (wd_rf)
                );
                
    mux2 #(5) rfwa_jal_mux (
                .sel            (jal),
                .a              (rf_wa_rdtW),
                .b              (5'd31),
                .y              (rf_wa_ra)
                );

    mux2 #(32) pcjr_mux (
                .sel            (jr),
                .a              (pc_next_pre),
                .b              (rsD),
                .y              (pc_next)
                );
                
    mux2 #(5) rfjr_mux (
                .sel            (jr),
                .a              (rf_wa_ra),
                .b              (5'd0),
                .y              (rf_wa)
                );
                
    // --- sll, srl Support --- //
    mux2 #(32) shift_mux (
                .sel            (shmux),
                .a              (ford_rsE),
                .b              (shamt_in),
                .y              (alu_pa)
                );
    // ***************************************************           
    // --- RF Logic --- //
    mux2 #(5) rf_wa_mux (
            .sel            (reg_dst),
            .a              (instrE[20:16]),
            .b              (instrE[15:11]),
            .y              (rf_wa_rdtE)
        );

    regfile rf (
            .clk            (clk),
            .we             (we_reg),
            .ra1            (instrD[25:21]),
            .ra2            (instrD[20:16]),
            .ra3            (ra3),
            .wa             (rf_wa),
            .wd             (wd_rf),
            .rd1            (rsD),
            .rd2            (wd_dmD),
            .rd3            (rd3)
        );

    signext se (
            .a              (instrD[15:0]),
            .y              (sext_immD)
        );
        
    
    // --- ALU Logic --- //
    mux2 #(32) alu_pb_mux (
            .sel            (alu_src),
            .a              (ford_rtE),
            .b              (sext_immE),
            .y              (alu_pb)
        );

    alu alu (
            .op             (alu_ctrl),
            .a              (alu_pa),
            .b              (alu_pb),
            //.zero           (zero),
            .y              (alu_outE)
        );

    // --- MULTIPLIER --- //
    multiplier_en mult(
            .A              (ford_rsE),
            .B              (ford_rtE),
            .en             (mult_enable),
            .Y              ({high_inE, low_inE})
            );
    
    // !UPDATE! low, high regs and sfmux are all in Memory Stage now
    dreg low_reg(
            .clk            (clk),
            .rst            (rst),
            .d              (low_inM),
            .q              (sfmux_in0)
            );
                    
    dreg high_reg(
            .clk            (clk),
            .rst            (rst),
            .d              (high_inM),
            .q              (sfmux_in1)
            );
    
    mux2 #(32) sfmux (
            .sel            (sfmux_high),
            .a              (sfmux_in0),
            .b              (sfmux_in1),
            .y              (sfmux_outM)
            );
            
    mux2 #(32) rf_sfhl_mux (
            .sel            (sf2reg),
            .a              (wd_aludm),
            .b              (sfmux_outW),
            .y              (wd_sfhl)
            );
        
    // --- MEM Logic --- //
    mux2 #(32) rf_aludm_mux (
            .sel            (dm2reg),
            .a              (alu_outW),
            .b              (rd_dmW),
            .y              (wd_aludm)
        );
        
endmodule