/* Date: 04/11/26
   Author : Amit S. 
   Design description:
 
       testbench for top module

*/


`timescale 1ns / 1ps    // set simulation resolution
`default_nettype none   // Turn off default net type declaration  

module top_tb; 


    reg   clk_sig = 1'b0; 
    reg   rst_sig = 1'b1; 
    wire   d_out ; 
    
    localparam integer C_CLK_PERIOD = 5.0 ;     // ns
    localparam integer  C_RESET_PERIOD = 300 ; // ns

    always
        begin
            # (C_CLK_PERIOD/2);
            clk_sig <= ~ clk_sig;  
        end    
    
    initial
        begin
            #(C_RESET_PERIOD);
            rst_sig <= 1'b0;
        end


    top top_inst
        (
            .clk_in (clk_sig),
            .rst_in (rst_sig), 
            .d_out  (d_out)
        );

endmodule // top_tb   

`default_nettype wire