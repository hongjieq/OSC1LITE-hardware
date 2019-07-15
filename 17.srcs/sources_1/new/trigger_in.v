`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/02 19:23:33
// Design Name: 
// Module Name: trigger_in
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


module trigger_in(
input wire trigger,
input wire clock,
input wire reset,
input wire resetflag,
output wire flag
    );
    wire present_stage;
    reg previous_stage;
   
  
always @(negedge clock)
begin
if(reset | resetflag)begin
previous_stage <= 1'b0;
end else begin
previous_stage<= present_stage;
end
end

assign present_stage = reset ? 0 : previous_stage ? 1 : trigger; 
assign flag = reset? 0: resetflag ? 0:previous_stage ? 1'b1
            : trigger ? 1'b1
            : 1'b0;
//assign present_stage = 1;
            
//always @(*)
//begin
//case (previous_stage)
//1'b0:begin
//    case(trigger)
//    1'b0: begin  flag <= 1'b0; end
//    1'b1: begin  flag <= 1'b1; end
//    endcase
//    end
//1'b1:begin
//    end
//endcase

endmodule