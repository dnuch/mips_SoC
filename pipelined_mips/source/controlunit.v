module controlunit (
        input wire         clk,
        input wire         rst,
        input  wire [5:0]  opcode,
        input  wire [5:0]  funct,
        output wire        branch, // D
        output wire        jump,   // D
        output wire        reg_dst,// E
        output wire        we_reg, // W
        output wire        alu_src,  // E
        output wire        we_dm,    // M
        output wire        dm2reg,   // W
        output wire [3:0]  alu_ctrl, // E
        output  wire        jr,      // D
        output  wire        jal,     // D
        output  wire        shmux,   // E
        output  wire        mult_enable,    // E
        output  wire        sfmux_high,     // W
        output  wire        sf2reg          // W
    );
    
    //wire [1:0] alu_op;  <-- replaced by alu_opD
    
    
    // ____________________________________
    // SIGNAL INITIALIZATION AND ASSIGNMENT    
    
    wire [12:0] signals_outD;
    wire [12:0] signals_inE;
    wire [4:0] signals_outE;
    wire [4:0] signals_inM;
    wire [3:0] signals_outM;
    wire [3:0] signals_inW;    
    
    // ____________decode_____________
    wire reg_dstD, we_regD, alu_srcD, we_dmD, dm2regD, shmuxD, mult_enableD, sfmux_highD, sf2regD;
    wire branchD, jumpD, jalD, jrD;
    wire [1:0] alu_opD;
    wire [3:0] alu_ctrlD; 
    // batch all decode-stage signals together (except for jumpD, jalD, jrD)
    assign signals_outD = {reg_dstD, we_regD, alu_srcD, we_dmD, dm2regD, alu_ctrlD, shmuxD, mult_enableD, sfmux_highD, sf2regD};   //alu_ctrlD 4 bit
    assign {branch, jump, jal, jr} = {branchD, jumpD, jalD, jrD};     // // in-use signals, note: alu_opD is used internally
    
    // ____________execute_____________
    wire reg_dstE, we_regE, alu_srcE, we_dmE, dm2regE, shmuxE, mult_enableE, sfmux_highE, sf2regE;
    wire [3:0] alu_ctrlE; 
    // batch all execute-stage signals that will go through stage register
    assign {reg_dstE, we_regE, alu_srcE, we_dmE, dm2regE, alu_ctrlE, shmuxE, mult_enableE, sfmux_highE, sf2regE} = signals_inE;    //alu_ctrlE 4 bit
    assign signals_outE = {we_regE, we_dmE, dm2regE, sfmux_highE, sf2regE};    
    assign {reg_dst, alu_src, alu_ctrl, shmux, mult_enable} = {reg_dstE, alu_srcE, alu_ctrlE, shmuxE, mult_enableE}; // in-use signals
    
    // ____________memory_____________
    wire we_regM, we_dmM, dm2regM, sfmux_highM, sf2regM;
    // batch all memory-stage signals that will go through stage register
    assign {we_regM, we_dmM, dm2regM, sfmux_highM, sf2regM} = signals_inM;   
    assign signals_outM = {we_regM, dm2regM, sfmux_highM, sf2regM};   
    assign we_dm = we_dmM;  // in-use signals
    
    // ____________write-back_____________
    wire we_regW, dm2regW, sfmux_highW, sf2regW;
    // batch all writeback-stage signals that will go through stage register
    assign {we_regW, dm2regW, sfmux_highW, sf2regW} = signals_inW;   
    assign {dm2reg, sfmux_high, sf2reg} = {dm2regW, sfmux_highW, sf2regW};  // in-use signals   

    assign we_reg = (jal == 1)? 1: we_regW;
    // ________________________________
    //      SET UP STAGE REGISTERS   
    
    // ____________execute_____________    
    dreg #13 decE_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (signals_outD),
                .q              (signals_inE)
            );
    // ____________memory_____________    
    dreg #5 decM_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (signals_outE),
                .q              (signals_inM)
            );
    // ____________write-back_________    
    dreg #4 decW_reg (
                .clk            (clk),
                .rst            (rst),
                .d              (signals_outM),
                .q              (signals_inW)
            );            

    // ________________________________
    //      DECODER MODULES       
    
    maindec md (
        .opcode         (opcode),
        .branch         (branchD), // D
        .jump           (jumpD), // D
        .jal            (jalD),  // D
        .reg_dst        (reg_dstD),
        .we_reg         (we_regD),
        .alu_src        (alu_srcD),
        .we_dm          (we_dmD),
        .dm2reg         (dm2regD),
        .alu_op         (alu_opD)
    );

    auxdec ad (
        .alu_op         (alu_opD),
        .funct          (funct),
        .alu_ctrl       (alu_ctrlD),
        .jr             (jrD),   // D
        .shmux          (shmuxD),
        .mult_enable    (mult_enableD),
        .sfmux_high     (sfmux_highD),
        .sf2reg         (sf2regD)        
    );

endmodule