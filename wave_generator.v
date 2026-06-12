module wave_generator(
  input  wire         clk,
  input  wire         rst_n, 
  input  wire         enable_i2c,
  input  wire  [ 1:0] freq_turn,    
  input  wire  [ 2:0] i_select_wave,  //1 SW[4:2]
  input  wire         i_noise,				//2 SW5
  input  wire         adj_amp,        //3 SW6
	input  wire         sign_on,        //  key 3
  output wire         aud_mclk,
  output wire         aud_bclk,
  output wire  [23:0] digital_value,
  output wire  [11:0] o_phase,
  output wire         daclrc,
  output wire         o_scl,
  inout  wire         o_sda,
  output wire         dacdat
);
 
  reg  [1:0]  counter; 
  wire [23:0] dds_out;
	wire clk_12M;
	wire clk_3M;
	
	
  assign aud_mclk = clk_12M;
  assign aud_bclk = clk_3M;
	
	pll_ip u_pll_inst (
	  .inclk0 (clk),
	  .c0     (clk_12M)
  );

  fsm_i2c_controller i2c_inst (
    .enable (enable_i2c),
    .rst_n  (rst_n),
    .clk    (clk),
    .o_scl  (o_scl),
    .o_sda  (o_sda)
  );

  i2s_transmitter i2s_inst (
    .bclk          (clk_3M),
    .rst_n         (rst_n),
    .digital_value (digital_value),
    .daclrc        (daclrc),
    .dacdat        (dacdat)
  );
	
	dds dds_dut(
		.clk           (clk_3M),
		.o_phase       (o_phase),
		.rst_n         (rst_n),
		.i_noise       (i_noise),
		.daclrc        (daclrc),
		.i_select_wave (i_select_wave),
		.digital_value (dds_out),
		.sign_on       (sign_on),
		.freq_turn     (freq_turn)
	);
	
  assign digital_value = (adj_amp) ? ({1'b0, dds_out[23:1]} + 24'h400000) : dds_out;

	always @(posedge clk_12M or negedge rst_n) begin
    if(!rst_n) begin
			counter <= 2'b0;
		end else begin
		  counter <= counter + 1'b1;
		end 	
	end
	
	assign clk_3M = counter[1];
	
endmodule
