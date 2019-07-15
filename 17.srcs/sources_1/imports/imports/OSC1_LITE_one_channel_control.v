`timescale 1ns / 1ps
`default_nettype none

module OSC1_LITE_Control(
	input  wire [7:0]  hi_in,
	output wire [1:0]  hi_out,
	inout  wire [15:0] hi_inout,
	inout  wire        hi_aa,

	output wire        hi_muxsel,
	

	input  wire		   clk,

	output wire [7:0]  led,



	/* Output pins*/
	/*
	output wire		clear5,
	output wire		latch5,
	output wire		sclk5,
	output wire		din5,
	input wire 		sdo_bit5,
	*/
	
	output wire [11:0] clear,
    output wire [11:0] latch,
    output wire [11:0] sclk,
    output wire [11:0] din,
    input wire [11:0] sdo_bit,
    input wire [11:0] trig_in,
    output wire [11:0] trig_out   	
	
	
	);

wire khan;
// Target interface bus:
wire         ti_clk;
wire [30:0]  ok1;
wire [16:0]  ok2;

wire [2:0]   sys_ctrl_pad1;
wire [12:0]  sys_ctrl_pad2;
wire [14:0]  sys_ctrl_pad3;
wire [12:0]  sys_ctrl_pad4;

reg [6:0] 	clk_counter;
wire[6:0]	division;



//input wire 		sdo_bit;
wire 		rst;
wire [11:0] pipe;	
wire [2:0]	div_mode;
wire [2:0]	mode;
wire 		clear_request;

reg [191:0] amplitude;
reg [191:0] pulse_width; 
reg [47:0]  option;
reg [191:0] wave_period;

wire [15:0] data_from_user_pulse_width;
wire [15:0] data_from_user_period;
wire [15:0] data_from_user_amp;
wire [15:0] data_from_user_mode;
wire [3:0] data_mode;
wire [3:0] addr;
wire data_trigger;
//wire [15:0]	data_from_user5;
//wire [15:0] current_to_dac_chip;
//wire [15:0] sdo;

wire 		pipe_in_write_enable;
wire 		pipe_out_read_enable;

wire [15:0]  	pipe_in_write_data;
wire [15:0]  	pipe_out_read_data;

wire [15:0]  	period;
wire [15:0]  	num_of_pulses;

wire [11:0]	spi_pipe_clk;
wire 		clk_pulse;
wire [191:0] result; 
wire [11:0] flag;
wire [11:0] resetflag;
wire [47:0] debug_counter;

assign hi_muxsel = 1'b0;
//assign current_to_dac_chip = pipe ? {pipe_out_read_data[1:0],pipe_out_read_data[15:8]} : data_from_user;
assign led = {flag[3:0], trig_in[3:0]};
//assign led = {pulse_width[19:16], pulse_width[3:0]};

assign trig_out[11:0] = 0;
assign division = (div_mode == 3'b001) ? 7'b0000100 : (div_mode == 3'b010) ? 7'b0010100 : (div_mode == 3'b011) ? 7'b0101000 : 7'b1000000;
//assign clk_pulse = clk;
assign clk_pulse = (div_mode == 3'b000) ? clk : (clk_counter == 0);

assign data_mode = data_from_user_mode[3:0];
assign addr = data_from_user_mode[7:4];
assign data_trigger = data_from_user_mode[8];

always @ (posedge data_trigger) begin
	amplitude[16*addr +: 16] = data_from_user_amp;
	pulse_width[16*addr +: 16] = data_from_user_pulse_width;
	wave_period[16*addr +: 16] = data_from_user_period;
	option[4*addr +: 4] = data_mode;
end

read_input calc[11:0](
    .clk(clk_pulse),//which clock to use?
    .rst(rst),
    .amplitude(amplitude[191:0]),
    .Cmax(wave_period[191:0]),
    .Cth(pulse_width[191:0]),
    .Option(option[47:0]),
    .flag(flag[11:0]),
    .result(result),
    .resetflag(resetflag[11:0]),
	.debug_counter(debug_counter)
);
trigger_in dotrigger[11:0](
    .trigger(trig_in[11:0]),//where are the triggers?
    .clock(clk_pulse),
    .reset(rst),
    .resetflag(resetflag[11:0]),
    .flag(flag[11:0])
    );


spi_controller dac_spi0 [11:0](
	.clk(clk_pulse), //(clk_counter[1]),	// Opal Kelly ti_clk
	.rst(rst),	// Opal Kelly reset
	.mode(mode), // Opal Kelly write bit: 2'b00 for nop, 2'b01 for write, 2'b10 for read
	.clear_request(clear_request),		// OK clr DAC pin

	.pipe(pipe[11:0]),
	.data_from_memory({pipe_out_read_data[7:0],pipe_out_read_data[15:8]}),
	.data_from_user(result),	// waveform_info


	.sdo_bit(sdo_bit),		

	.clear(clear),	// DAC input clr
	.latch(latch),	// DAC input latch
	.sclk(sclk),	// DAC input sclk
	.din(din),
	.spi_pipe_clk(spi_pipe_clk)
    );

/*
spi_controller dac_spi(
	.clk(clk), //(clk_counter[1]),	// Opal Kelly ti_clk
	.rst(rst),	// Opal Kelly reset
	.mode(mode), // Opal Kelly write bit: 2'b00 for nop, 2'b01 for write, 2'b10 for read
	.clear_request(clear_request),		// OK clr DAC pin
	.pipe(pipe),
	.data_from_memory({pipe_out_read_data[7:0],pipe_out_read_data[15:8]}),
	.data_from_user(data_from_user5),	// waveform_info
	.sdo_bit(sdo_bit5),		
	//.sdo(sdo),
	// .sdo(sdo),		// DAC output sdo[15:0]. Should contain read data only when read from register
					// For non-feedback control purpose, this variable should not be affecting functionality. See Manual Page 10.
	.clear(clear5),	// DAC input clr
	.latch(latch5),	// DAC input latch
	.sclk(sclk5),	// DAC input sclk
	.din(din5),		// DAC input din
	.spi_pipe_clk(spi_pipe_clk)
    );
*/


amp_pipe my_amp_pipe(
	.ti_clk(ti_clk),
	.reset(rst),
	.clk(spi_pipe_clk[0]),
	.period(period),
	.num_of_pulses(num_of_pulses),
	
	.pipe_in_write_trigger(pipe_in_write_enable),
	.pipe_in_write_data(pipe_in_write_data),
	
	.pipe_out_read_trigger(pipe_out_read_enable),
	.pipe_out_read_data(pipe_out_read_data),
	.khan(khan)
	
);


okHost okHI(
	.hi_in(hi_in), .hi_out(hi_out), .hi_inout(hi_inout), .hi_aa(hi_aa), .ti_clk(ti_clk),
	.ok1(ok1), .ok2(ok2));

wire [17*2-1:0]  ok2x;
okWireOR # (.N(2)) wireOR (ok2, ok2x);
okWireIn     wi00 (.ok1(ok1),                           .ep_addr(8'h00), .ep_dataout({sys_ctrl_pad1, pipe, rst}));
okWireIn     wi01 (.ok1(ok1),                           .ep_addr(8'h01), .ep_dataout({sys_ctrl_pad2, mode}));
okWireIn     wi02 (.ok1(ok1),                           .ep_addr(8'h02), .ep_dataout({sys_ctrl_pad3,clear_request}));

okWireIn     wi03 (.ok1(ok1),                           .ep_addr(8'h03), .ep_dataout(data_from_user_pulse_width[15:0]));
okWireIn     wi04 (.ok1(ok1),                           .ep_addr(8'h04), .ep_dataout(data_from_user_period[15:0]));
okWireIn     wi05 (.ok1(ok1),                           .ep_addr(8'h05), .ep_dataout(data_from_user_amp[15:0]));
okWireIn     wi06 (.ok1(ok1),                           .ep_addr(8'h06), .ep_dataout(data_from_user_mode[15:0]));

okWireIn     wi15 (.ok1(ok1),                           .ep_addr(8'h15), .ep_dataout(period[15:0]));
okWireIn     wi16 (.ok1(ok1),                           .ep_addr(8'h16), .ep_dataout(num_of_pulses[15:0]));
okWireIn     wi17 (.ok1(ok1),                           .ep_addr(8'h17), .ep_dataout({sys_ctrl_pad4, div_mode}));

/*
okWireIn     wi03 (.ok1(ok1),                           .ep_addr(8'h03), .ep_dataout(data_from_user[15:0]));
okWireIn     wi04 (.ok1(ok1),                           .ep_addr(8'h04), .ep_dataout(data_from_user[31:16]));
okWireIn     wi05 (.ok1(ok1),                           .ep_addr(8'h05), .ep_dataout(data_from_user[47:32]));
okWireIn     wi06 (.ok1(ok1),                           .ep_addr(8'h06), .ep_dataout(data_from_user[63:48]));
okWireIn     wi07 (.ok1(ok1),                           .ep_addr(8'h07), .ep_dataout(data_from_user[79:64]));
okWireIn     wi08 (.ok1(ok1),                           .ep_addr(8'h08), .ep_dataout(data_from_user[95:80]));


okWireIn     wi09 (.ok1(ok1),                           .ep_addr(8'h09), .ep_dataout(data_from_user[111:96]));
okWireIn     wi0a (.ok1(ok1),                           .ep_addr(8'h0A), .ep_dataout(data_from_user[127:112]));
okWireIn     wi0b (.ok1(ok1),                           .ep_addr(8'h0B), .ep_dataout(data_from_user[143:128]));
okWireIn     wi0c (.ok1(ok1),                           .ep_addr(8'h0C), .ep_dataout(data_from_user[159:144]));
okWireIn     wi0d (.ok1(ok1),                           .ep_addr(8'h0D), .ep_dataout(data_from_user[175:160]));
okWireIn     wi0e (.ok1(ok1),                           .ep_addr(8'h0E), .ep_dataout(data_from_user[191:176]));

//below are Cth input part 1
okWireIn     wi0f (.ok1(ok1),                           .ep_addr(8'h0F), .ep_dataout(data_from_user_extra[15:0]));
okWireIn     wi10 (.ok1(ok1),                           .ep_addr(8'h10), .ep_dataout(data_from_user_extra[31:16]));
okWireIn     wi11 (.ok1(ok1),                           .ep_addr(8'h11), .ep_dataout(data_from_user_extra[47:32]));
okWireIn     wi12 (.ok1(ok1),                           .ep_addr(8'h12), .ep_dataout(data_from_user_extra[63:48]));
okWireIn     wi13 (.ok1(ok1),                           .ep_addr(8'h13), .ep_dataout(data_from_user_extra[79:64]));
okWireIn     wi14 (.ok1(ok1),                           .ep_addr(8'h14), .ep_dataout(data_from_user_extra[95:80]));
//below are Cth input part 2
okWireIn     wi18 (.ok1(ok1),                           .ep_addr(8'h18), .ep_dataout(data_from_user_extra[111:96]));
okWireIn     wi19 (.ok1(ok1),                           .ep_addr(8'h19), .ep_dataout(data_from_user_extra[127:112]));
okWireIn     wi1a (.ok1(ok1),                           .ep_addr(8'h1A), .ep_dataout(data_from_user_extra[143:128]));
okWireIn     wi1b (.ok1(ok1),                           .ep_addr(8'h1B), .ep_dataout(data_from_user_extra[159:144]));
okWireIn     wi1c (.ok1(ok1),                           .ep_addr(8'h1C), .ep_dataout(data_from_user_extra[175:160]));
okWireIn     wi1d (.ok1(ok1),                           .ep_addr(8'h1D), .ep_dataout(data_from_user_extra[191:176]));

okWireIn     wi1e (.ok1(ok1),                           .ep_addr(8'h1E), .ep_dataout(data_from_user_extra[207:192]));
okWireIn     wi1f (.ok1(ok1),                           .ep_addr(8'h21), .ep_dataout(data_from_user_extra[223:208]));
okWireIn     wi20 (.ok1(ok1),                           .ep_addr(8'h22), .ep_dataout(data_from_user_extra[239:224]));

// below are Cmax input
okWireIn     wi21 (.ok1(ok1),                           .ep_addr(8'h1F), .ep_dataout(data_from_user_period[15:0]));
okWireIn     wi22 (.ok1(ok1),                           .ep_addr(8'h20), .ep_dataout(data_from_user_period[31:16]));
okWireIn     wi23 (.ok1(ok1),                           .ep_addr(8'h23), .ep_dataout(data_from_user_period[47:32]));
okWireIn     wi24 (.ok1(ok1),                           .ep_addr(8'h24), .ep_dataout(data_from_user_period[63:48]));
okWireIn     wi25 (.ok1(ok1),                           .ep_addr(8'h25), .ep_dataout(data_from_user_period[79:64]));
okWireIn     wi26 (.ok1(ok1),                           .ep_addr(8'h26), .ep_dataout(data_from_user_period[95:80]));
okWireIn     wi27 (.ok1(ok1),                           .ep_addr(8'h27), .ep_dataout(data_from_user_period[111:96]));
okWireIn     wi28 (.ok1(ok1),                           .ep_addr(8'h28), .ep_dataout(data_from_user_period[127:112]));
okWireIn     wi29 (.ok1(ok1),                           .ep_addr(8'h29), .ep_dataout(data_from_user_period[143:128]));
okWireIn     wi2a (.ok1(ok1),                           .ep_addr(8'h2A), .ep_dataout(data_from_user_period[159:144]));
okWireIn     wi2b (.ok1(ok1),                           .ep_addr(8'h2B), .ep_dataout(data_from_user_period[175:160]));
okWireIn     wi2c (.ok1(ok1),                           .ep_addr(8'h2C), .ep_dataout(data_from_user_period[191:176]));
*/

//okWireOut    wo21 (.ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h21), .ep_datain(sdo));
//okWireOut    wo22 (.ok1(ok1), .ok2(ok2x[ 1*17 +: 17 ]), .ep_addr(8'h22), .ep_datain({15'b0,pipe}));

okPipeIn	pi80 ( .ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h80), .ep_write(pipe_in_write_enable), .ep_dataout(pipe_in_write_data));
okPipeOut poa0 ( .ok1(ok1), .ok2(ok2x[ 1*17 +: 17 ]), .ep_addr(8'hA0), .ep_read(pipe_out_read_enable), .ep_datain(pipe_out_read_data));


always @ (posedge clk or posedge rst) begin
	if(rst) begin
		clk_counter <= 0;
	end else if(clk_counter < division)begin
		clk_counter <= clk_counter + 1;
	end else begin
		clk_counter <= 0;
	end
end

endmodule