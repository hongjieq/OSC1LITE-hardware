`timescale 1ns / 1ps
/*
OSC1 - LITE
Yoon's Lab - U of M
*/

module spi_controller(
	/* Input pins*/
	input  wire			      clk,	// Opal Kelly ti_clk
	input  wire			      rst,	// Opal Kelly reset
	input  wire [2:0]		   mode, // Opal Kelly write bit: 3'b000 for nop, 3'b001 for write, 3'b010 for read, 3'b011 for control, 3'b100 for reset, 3'b101 for config
	input  wire 			   clear_request,	// OK clr DAC pin
	
	
	input  wire					pipe,
	input  wire [15:0]	  	data_from_memory,
	
	input  wire [15:0]	  	data_from_user,	// waveform_info



	input  wire 		  	   sdo_bit,		

	/* Output pins*/
	//output reg [15:0]		  sdo,
	output wire			      clear,	// DAC input clr
	output reg			      latch,	// DAC input latch
	output wire			      sclk,		// DAC input sclk
	output reg			      din,		// DAC input din

	output wire               spi_pipe_clk
    );

wire [7:0] 	address_byte;
wire [23:0] full_command;

reg  [4:0] 	counter;				// 0 - 23 to clock in the command. 24 - 29 to relax latch HIGH. t5 min = 40ns on Page 9.
wire [4:0]	shift_counter_helper;	// Shifting bit from full_command to din

//reg  [15:0] raw_sdo;

assign shift_counter_helper = ~counter + 5'd24;  // (0 -> 23, 1 -> 22, etc.)

assign clear = clear_request; 								// assign OK clr DAC pin control to clr DAC register. 
//assign sclk = clk;											// assign spi input clk equal to Opal Kelly ti_clk
assign sclk = (counter >= 5'd24) ? 0 :clk;
assign address_byte = (mode == 3'b001) ? 8'b00000001 		// wirte (See Manual Page 32, 33)
		    : (mode == 3'b010) ? 8'b00000010                // read
		    : (mode == 3'b011) ? 8'b01010101                // write control
		    : (mode == 3'b100) ? 8'b01010110                // write reset
		    : (mode == 3'b101) ? 8'b01010111                // write config
		    : (mode == 3'b110) ? 8'b01011000                // write DAC gain calibration
            : (mode == 3'b111) ? 8'b01011001                // write DAC zero calibration
		    : 8'b0;			
															
assign full_command = (mode == 3'b010) ?  {address_byte, 16'b0000000000000010} // if read, set read DAC config register
					: (mode == 3'b100) ?  {address_byte, 16'b0000000000000001} // if reset, set RST bit to 1
					: (mode == 3'b011) ?  {address_byte, 16'b0001000000000111} // if set control
					: (mode == 3'b101) ?  {address_byte, 16'b0000000000000000} // if config, set WD bits to 0
					: (mode == 3'b000) ?  {address_byte, 16'b0000000000000000}
					:  pipe ? {address_byte, data_from_memory} 
					: {address_byte, data_from_user};			// if write, {address_byte -> [23:16], data_from_user -> [15:0]}

assign spi_pipe_clk = (counter == 5'd29);

always @ (negedge clk) begin
	if(rst) begin
		counter <= 0;
//		raw_sdo	<= 0;
	end else begin
		counter <= counter + 1;
//		raw_sdo	<= {raw_sdo[14:0], sdo_bit};
	end
end


always @ (negedge clk) begin
	if(counter >= 5'd23) begin
        if(counter < 5'd29) begin
            latch <= 1'b1;
        end else begin
            latch <= 1'b0;
        end
    end else begin
        latch <= 1'b0;
    end
end

always @ (*) begin

	if(counter >= 5'd23) begin
		if(counter < 5'd24) begin
			din = (full_command >> shift_counter_helper) & 1'b1;
		//	sdo = raw_sdo;
		end else if(counter < 5'd29) begin
			din = 1'b0;
		end else begin
			din = 1'b0;
		end
	end else begin
		din = (full_command >> shift_counter_helper) & 1'b1;
	end
end
		
endmodule
