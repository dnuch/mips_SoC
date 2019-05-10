`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2019 10:51:07 AM
// Design Name: 
// Module Name: hazard_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// NOTE: HAZARD UNIT IS COMPLETELY COMBINATIONAL
module hazard_unit (
        // Inputs from datapath
        input  wire [4:0]       rsD,
        input  wire [4:0]       rtD,
        input  wire [4:0]       rsE,
        input  wire [4:0]       rtE,
        input wire [4:0]       rf_waE,
        input wire [4:0]       rf_waM,
        input wire [4:0]       rf_waW,
        // Inputs from control unit
        input wire         we_regE,
        input wire         we_regM,
        input wire         we_regW,
        input wire         sf2regM,
        input wire         dm2regE, 
        input wire         dm2regM, 
        input wire         branchD,
        // Output
        output wire StallF,
        output wire StallD,
        output wire FlushE,
        output wire fordAD,
        output wire fordBD,
        output reg [1:0] fordAE,
        output reg [1:0] fordBE,
        output wire fordMultM
);

wire lwstall;
wire branchstall;

assign fordAD = (rsD !=0) && (rsD == rf_waM) && we_regM;
assign fordBD = (rtD !=0) && (rtD == rf_waM) && we_regM;
assign fordMultM = (sf2regM)? 1:0;
assign lwstall       = ((rsD == rtE) || (rtD == rtE)) && dm2regE;
assign branchstall   = (branchD && we_regE && (rf_waE == rsD || rf_waE == rtD)) || (branchD && dm2regM && (rf_waM == rsD || rf_waM == rtD));
assign StallF = lwstall || branchstall;
assign StallD = lwstall || branchstall;
assign FlushE = lwstall || branchstall;

// DATA FORWARDING at EXECUTION
always @ (rsE, rtE, rf_waM, we_regM, rf_waW, we_regW)
begin
    // for rs
    if      ((rsE != 0) && (rsE == rf_waM) && we_regM)      fordAE = 10;
    else if ((rsE != 0) && (rsE == rf_waW) && we_regW)      fordAE = 01;
    else                                                    fordAE = 00;
    // for rt
    if      ((rtE != 0) && (rtE == rf_waM) && we_regM)      fordBE = 10;
    else if ((rtE != 0) && (rtE == rf_waW) && we_regW)      fordBE = 01;
    else                                                    fordBE = 00;
end

endmodule
