/* Date: 02/11/26
   Author : Amit S. 
   Design description:
 
     this design implements dual clock flip flop */

`timescale 1ns / 1ps  // define simulation resolution
`default_nettype none // Turn off implicit net declaration

module dual_clock_ff 
    (
        input wire d_in,
        input wire clk,
        input wire rst_r,  // reset syncronous with rising edge of clock
        input wire rst_n,  // reset synchronous with falling edge of clock
        output wire d_out 
    );


    reg d_pos;
    reg d_neg;

    // rising edge ff
    always @(posedge rst_r or posedge clk)
        begin
            if (rst_r) 
                d_pos <= 1'b0;
            else
                d_pos <= d_in ^ d_neg;
        end
        
        
    //falling edge ff
    always @(posedge rst_n, negedge clk)
        begin
            if (rst_n) 
                d_neg <= 1'b0;
            else
                d_neg <= d_in ^ d_pos;
        end



    assign d_out = d_pos ^ d_neg;


    
endmodule // dual_clock_ff 

`default_nettype wire    // restore default for whatever comes next

