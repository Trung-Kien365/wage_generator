module dds(
  input wire         clk,
  input wire         rst_n,
  input wire         i_noise,
	input wire         sign_on,
	input wire 				 daclrc,
  input wire  [ 2:0] i_select_wave, 
  output wire [23:0] digital_value,
	output wire [11:0] o_phase,
  input wire  [ 1:0] freq_turn
);

  wire [23:0] sine;
  reg  [23:0] square;
  wire [23:0] triangle;
  wire [23:0] sawtooth;
  wire [23:0] ecg;
	
	wire [23:0] signed_wave_out;
	reg  [11:0] freq;
	reg         negedge_daclrc;
	wire 		    neg_edge;
  wire [24:0] step;

  reg  [11:0] phase_register;
  reg  [23:0] original_wave;
  wire [23:0] noise_wave;
 
	sine_rom u_sine(
	  .address (o_phase),
	  .clock   (clk),
	  .q       (sine)
	  );

  sawtooth_wave u_sawtooth(
    .clk           (clk),
    .rst_n         (rst_n),
    .en_48khz      (neg_edge),
    .freq_turn     (freq_turn),
    .sawtooth_wave (sawtooth)
  );
		
  triangle_wave u_triangle(
  .clk           (clk),
  .rst_n         (rst_n),
  .en_48khz      (neg_edge),
  .freq_turn     (freq_turn),
  .triangle_wave (triangle)
  );

	ecg_rom u_ecg(
	  .address (o_phase),
	  .clock   (clk),
	  .q       (ecg)
	  );
		 
  noise_mixer_top noise_dut(
    .clk(clk),
    .rst_n(rst_n),
    .sw_gain(3'b111),
    .wave_in(original_wave),
    .mixed_out(noise_wave)
  );
	
  // Phase accumulator
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      phase_register <= 12'b0;
			negedge_daclrc <= 1'b0;
    end else begin
			if(neg_edge) begin
				phase_register <= phase_register + {freq};
			end else begin
				phase_register <= phase_register;
			end
      
			negedge_daclrc <= daclrc;

      if(sawtooth[23]) 
        square <= 24'd8388607;
      else
        square <= 24'd8388608;
    end 
  end
	
	assign neg_edge = negedge_daclrc && (~daclrc);
	assign o_phase = phase_register;
		
	always @(*) begin
    case(freq_turn)
      2'b00: freq = 12'd1;    // 11.7 Hz
      2'b01: freq = 12'd10;   // 117.2 Hz
      2'b10: freq = 12'd100;  // 1171.9 Hz
      2'b11: freq = 12'd200;  // 2343.8 Hz
      default: freq = 12'd430; // 
    endcase
  end
	
  always @(*) begin
    case(i_select_wave)
      3'b000: original_wave = sine;
      3'b001: original_wave = square;
      3'b010: original_wave = triangle;
      3'b011: original_wave = sawtooth;
      3'b100: original_wave = ecg;
      default: original_wave = sine;
    endcase 
  end

  assign signed_wave_out = (i_noise) ? noise_wave : original_wave;
  assign digital_value = (!sign_on) ? signed_wave_out : {~signed_wave_out[23], signed_wave_out[22:0]};

endmodule