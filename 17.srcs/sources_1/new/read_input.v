`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/02 19:58:37
// Design Name: 
// Module Name: read_input
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


module read_input( // need to be called 12 times 
    input wire clk,//input clock
    input wire	rst,	// Opal Kelly reset
    input wire [15:0] amplitude,//amplitude of square waves 
    input wire [15:0] Cmax,//Cmax = clk frequency/sampling frequency - 1
    input wire [15:0] Cth,//Dutycycle * (Cmax + 1)
    input wire [3:0] Option,//choose rising time: 0 for 0 msec, 1 for 0.1 msec, 2 for 0.5 msec, 3 for 1 msec, 4 for 2 msec
    input wire flag,//1 for output, 0 for no output
    //input wire [4:0] numberofwaves,//number of waves 
    output wire [15:0] result,//square wave information of one module
    output wire resetflag,
	output wire [3:0] debug_counter
	//output wire [7:0] num_waves
   );
    reg [31:0] counter = 0;
    reg [7:0] counter1 = 0;//number of waves have been output
    wire [5:0] mult;
    //reg [15:0] Cmax = 16'b1111111111111110;
    wire [17:0] C;
	
	//assign num_waves = counter1;
	assign debug_counter = counter[26:23];
    
    assign C[17:2] = Cth[15:0];
    assign C[1:0] = 2'b00;
    assign resetflag = (counter1 >= 8'd10) ? 1'b1 : 1'b0;
    assign mult = (Option == 4'd0) ? 6'd1
                : (Option == 4'b1) ? 6'd3
                : (Option == 4'd2) ? 6'd13
                : (Option == 4'd3) ? 6'd25
                : (Option == 4'd4) ? 6'd50
                :  6'd0;
   
     assign result = (flag == 0) ? 1'b0
                   :(counter[26:9] < mult) ? (amplitude*counter[26:9])
                   :(counter[26:9] < (C - mult)) ? (amplitude * mult)
                   :(counter[26:9] < C) ? (amplitude * (C - counter[26:9]))
                   : 1'b0;

    
    always @ (negedge clk) begin
        if(rst) begin
            counter <= 0;
            counter1 <= 0;
        end 
        if(flag == 0) begin
            counter <= 0;
            counter1 <= 0;
        end
        else if(counter[26:11] >= Cmax) begin
            counter <= 0;
            counter1 <= counter1 + 1;
        end
        else begin
         counter <= counter + 1;
        end 
          
    end
endmodule