// Date: 24/10/26
// Author : Amit S. 
// Design description:

//      generates narrow pulse between rising and falling clock edge 
 
`timescale 1ns / 1ps  // define simulation resolution
`default_nettype none // Turn off implicit net declaration

module narrow_pulse_gen 
    ( 
        input  wire rst_p,
        input  wire rst_n,
        input  wire clk, 
        output wire pulse_out 
    );

   
    localparam [5:0] C_CNT_MAX = 6'd50; // maximum counter value
    reg [5:0] counter ; // actually counts from 0 to C_CNT_MAX
    reg step_p  ;
    reg step_n  ;

    // rising edge counter
    always @(posedge rst_p, posedge clk)
        begin
            if (rst_p)
                counter <= 6'd0;
            else
                if (counter == C_CNT_MAX)
                    counter <= counter;
                else 
                    counter <= counter + 6'd1;
                             
        end     
        


    // rising edge step generation
    always @ (posedge rst_p, posedge clk)
        begin
            if (rst_p) 
                step_p <= 1'b0;
            else 
                if (counter == C_CNT_MAX) 
                    step_p <= 1'b1;
        end         
                
        

    // falling edge step gen
    always @ (posedge rst_n, negedge clk)
        begin
            if (rst_n) 
                step_n <= 1'b0;
            else 
                if (step_p == 1'b1) 
                    step_n <= 1'b1;
        end          
                
        
    // narrow pulse generation
    assign pulse_out = step_p ^ step_n;

endmodule // narrow_pulse_gen

`default_nettype wire    // restore default for whatever comes next
