/* Date: 24/10/26
   Author : Amit S. 
   Design description:
 
       this is testbench for dual clock flip flop check
*/

`timescale 1ns/1ps    // simulation resolution 
`default_nettype none  // Turn off implicit net declaration

module dual_clock_ff_tb;  

    
    localparam integer C_CLK_PERIOD = 20.0;   // ns
    localparam integer C_RST_PERIOD = 29.0;   // ns

    reg rst_sig  = 1'b1; 
    reg d_in_sig = 1'b0;
    reg clk_sig  = 1'b0; 

    wire rst_f_sig    ;
    wire rst_r_sig    ;
    wire d_out_0_sig  ;
    wire d_out_1_sig  ;
    wire d_out_2_sig  ;
    
 
    // reset release
    initial
        # (C_RST_PERIOD) rst_sig <= 1'b0; 


    // clock generation
    always
        # (C_CLK_PERIOD/2) clk_sig <= ~ clk_sig;   
        
        
    // reset synchronizer to falling clock edge 
    rst_sync_f # (
                    .G_STAGES_NUM (3)            // Number of synchronization FFs
                ) rst_sync_f_inst
                ( 
                    .clk            (clk_sig),   // clock for reset synchronization
                    .rst_async_in   (rst_sig),   // Asynchronous reset input  (active high)
                    .rst_sync_out_f (rst_f_sig)  // Synchronized reset output (active high)
                );


    // reset synchronizer to rising clock edge 
    rst_sync_r # (
                    .G_STAGES_NUM (3)         // Number of synchronization FFs
                ) rst_sync_r_inst
                ( 
                    .clk              (clk_sig),   // clock for reset synchronization
                    .rst_async_in     (rst_sig),   // Asynchronous reset input  (active high)
                    .rst_sync_out_r   (rst_r_sig)  // Synchronized reset output (active high)
                );

    initial
        begin
            # (C_CLK_PERIOD*10);
            @ (posedge clk_sig); 
            # (C_CLK_PERIOD-1);
            d_in_sig <= 1'b1;
            @ (posedge clk_sig); 
            # ((C_CLK_PERIOD/2)*4);
            @ (negedge clk_sig);
            # (C_CLK_PERIOD-1);
            d_in_sig <= 1'b0;
            @ (posedge clk_sig);
            # ((C_CLK_PERIOD/2)*2);
            @ (posedge clk_sig);
            # (C_CLK_PERIOD-1);                
            d_in_sig <= 1'b1;
            @ (posedge(clk_sig));
            # ((C_CLK_PERIOD/2)*2);
            @ (negedge(clk_sig));
            # (C_CLK_PERIOD-1);
            d_in_sig <= 1'b0;                
             
        end 

        // first stage
        dual_clock_ff dual_clock_ff_inst0
            (
                .d_in   (d_in_sig), 
                .clk    (clk_sig),
                .d_out  (d_out_0_sig),
                .rst_r  (rst_r_sig),    // reset syncronous with rising edge of clock
                .rst_n  (rst_f_sig)     // reset synchronous with falling edge of clock
            );

        // second stage
        dual_clock_ff dual_clock_ff_inst1
            (
                .d_in   (d_out_0_sig), 
                .clk    (clk_sig),
                .d_out  (d_out_1_sig),
                .rst_r  (rst_r_sig),   // reset syncronous with rising edge of clock
                .rst_n  (rst_f_sig)    // reset synchronous with falling edge of clock
            );
        
        // third stage
        dual_clock_ff dual_clock_ff_inst2 
            (
                .d_in   (d_out_1_sig), 
                .clk    (clk_sig),
                .d_out  (d_out_2_sig),
                .rst_r  (rst_r_sig),   // reset syncronous with rising edge of clock
                .rst_n  (rst_f_sig)    // reset synchronous with falling edge of clock
            );        
        
        
endmodule     

`default_nettype wire