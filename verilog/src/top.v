/* Date: 02/11/26
   Author : Amit S. 
   Design description:
 
        Top-level design file containing a small design for evaluating
        dual-edge flip-flop logic (rising and falling clock edges).
        It meets timing at a 300 MHz clock on a Kintex-7 -1 speed-grade FPGA,
        where it generates a pulse width of half a clock period (1.67 ns).
*/

`timescale 1ns/1ps     // set simulation resolution
`default_nettype none  // Turn off implicit net declaration

module top 
    (
        input  wire clk_in, 
        input  wire rst_in, 
        output wire d_out   
    );
    
    wire narrow_pulse;
    wire clk; 
    wire rst_f_sig;
    wire rst_r_sig;
    wire d_out_0_sig;
    wire d_out_1_sig;
    wire d_out_2_sig;

        // global buffer for clock
        BUFG clk_bufg_inst
            (.I (clk_in), 
             .O (clk)
            ); 
  
        // reset synchronizer to falling clock edge 
        rst_sync_f # ( .G_STAGES_NUM (3) ) rst_sync_f_inst   // Number of synchronization FFs
            ( 
                .clk            (clk),              // clock for reset synchronization
                .rst_async_in   (rst_in),           // Asynchronous reset input  (active high)
                .rst_sync_out_f (rst_f_sig)         // Synchronized reset output (active high)
            );


        // reset synchronizer to rising clock edge 
        rst_sync_r # (.G_STAGES_NUM (3)) rst_sync_r_inst    // Number of synchronization FFs
            ( 
                .clk            (clk),                  // clock for reset synchronization
                .rst_async_in   (rst_in),      // Asynchronous reset input  (active high)
                .rst_sync_out_r (rst_r_sig)  // Synchronized reset output (active high)
            );


        // generate pulse between rising and falling clock edge
        narrow_pulse_gen pulse_gen_inst 
            ( 
                .rst_p     (rst_r_sig), 
                .rst_n     (rst_f_sig), 
                .clk       (clk), 
                .pulse_out (narrow_pulse)
            );
        
        // first dual clock FF stage
        dual_clock_ff dual_clock_ff_inst0 
            (
                .d_in       (narrow_pulse), 
                .clk        (clk),
                .d_out      (d_out_0_sig),
                .rst_r      (rst_r_sig),          // reset syncronous with rising edge of clock
                .rst_n      (rst_f_sig)           // reset synchronous with falling edge of clock
            );

        // second dual clock FF stage
        dual_clock_ff dual_clock_ff_inst1
            (
                .d_in       (d_out_0_sig), 
                .clk        (clk),
                .d_out      (d_out_1_sig),
                .rst_r      (rst_r_sig),          // reset syncronous with rising edge of clock
                .rst_n      (rst_f_sig)           // reset synchronous with falling edge of clock
            );
        
        // third dual clock FF stage
        dual_clock_ff dual_clock_ff_inst2
            (
                .d_in       (d_out_1_sig), 
                .clk        (clk),
                .d_out      (d_out_2_sig),
                .rst_r      (rst_r_sig),      // reset syncronous with rising edge of clock
                .rst_n      (rst_f_sig)       // reset synchronous with falling edge of clock
            );   



        // ODDR: Output Double Data Rate Output Register with Set, Reset
        // and Clock Enable.
        // 7 Series-- Xilinx HDL Language Template, version 2026.1
        ODDR #  (
                    .DDR_CLK_EDGE ("OPPOSITE_EDGE"),     // "OPPOSITE_EDGE" or "SAME_EDGE"
                    .INIT         (1'b0),                // Initial value for Q port ('1' or '0')
                    .SRTYPE       ("SYNC")               // Reset Type ("ASYNC" or "SYNC")
                ) ODDR_inst 
                (
                    .Q    (d_out),           // 1-bit DDR output
                    .C    (clk),             // 1-bit clock input
                    .CE   (1'b1),            // 1-bit clock enable input
                    .D1   (d_out_2_sig),     // 1-bit data input (positive edge)
                    .D2   (d_out_2_sig),     // 1-bit data input (negative edge)
                    .R    (1'b0),            // 1-bit reset input
                    .S    (1'b0)             // 1-bit set input
                );    


endmodule // top

`default_nettype wire    // restore default for whatever comes next   