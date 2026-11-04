/* Date: 24/10/26
   Author : Amit S. 
   Design description:
 
       reset synchronizer for Vivado for falling clock edge
*/


`timescale 1ns / 1ps   // simulation resolution
`default_nettype none  // Turn off implicit net declaration

module rst_sync_f 
    #( parameter integer G_STAGES_NUM = 3 ) // Number of synchronization FFs
    ( 
        input  wire clk,           // clock for reset synchronization
        input  wire rst_async_in,  // Asynchronous reset input  (active high)
        output wire rst_sync_out_f // Synchronized reset output (active high)
    );


    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) // Vivado attributes for sig_sync_ff
    reg [G_STAGES_NUM-1:0] sig_sync_ff ;

    integer i;

    always @ (negedge clk, posedge rst_async_in)
        begin
            if (rst_async_in) 
                sig_sync_ff <= {G_STAGES_NUM{1'b1}}; // replication
            else 
                begin
                    sig_sync_ff[0] <= 1'b0;

                    for (i=1 ; i<G_STAGES_NUM ; i=i+1)
                        sig_sync_ff[i] <= sig_sync_ff[i-1];
                end    
        end
    

    assign rst_sync_out_f = sig_sync_ff[G_STAGES_NUM-1];

endmodule //rst_sync_f 

`default_nettype wire    // restore default for whatever comes next
