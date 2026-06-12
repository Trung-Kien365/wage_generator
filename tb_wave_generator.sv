`timescale 1ns/1ps

module tb_wave_generator;
  reg clk;
  reg rst_n;
  reg enable_i2c;
  reg [1:0] freq_turn;
  reg [2:0] i_select_wave;
  reg i_noise;

  wire aud_mclk;
  wire aud_bclk;
  reg  adj_amp;
  wire [23:0] digital_value;
  wire [11:0] o_phase;
  wire daclrc;
  wire o_scl;
  wire dacdat;
	reg  sign_on;

  wire o_sda;
  pullup(o_sda);

  wave_generator uut (
    .adj_amp (adj_amp),
	  .sign_on (sign_on),
    .clk(clk),
    .rst_n(rst_n),
		.o_phase(o_phase),
    .enable_i2c(enable_i2c),
    .freq_turn(freq_turn),
    .i_select_wave(i_select_wave),
    .i_noise(i_noise),
    .aud_mclk(aud_mclk),
    .aud_bclk(aud_bclk),
    .digital_value(digital_value),
    .daclrc(daclrc),
    .o_scl(o_scl),
    .o_sda(o_sda),
    .dacdat(dacdat)
    );

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb_wave_generator.uut.dds_dut.u_triangle);
  end 

  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  initial begin
	  rst_n = 0; enable_i2c = 0; freq_turn = 2'b11;
    i_select_wave = 3'b000; i_noise = 0; sign_on = 1;
    adj_amp = 0;
    #100;		
    rst_n = 1;
    #200;
		
    enable_i2c = 1; #1000000; 
    enable_i2c = 0; 

    $display("Time:[%0t] | Sine wave", $time);
    #1500000;
	  
    $display("Time:[%0t] | Square wave", $time);
    i_select_wave = 3'b001; #3000000;

    $display("Time:[%0t] | Triangle wave", $time);
		i_select_wave = 3'b010; #3000000;

    $display("Time:[%0t] | Sawtooth wave", $time);
  	i_select_wave = 3'b011; #3000000;

    $display("Time:[%0t] | Ecg wave", $time);
	  i_select_wave = 3'b100; #1500000;

    $display("Time:[%0t] | Sine wave + Noise", $time);
    i_select_wave = 3'b000; i_noise = 1; #2000000;

    $display("Time:[%0t] | Sine wave + Adjust Amplifier", $time);
    i_select_wave = 3'b000; i_noise = 1; adj_amp = 1;
    #1500000;
    $finish;
    end

endmodule