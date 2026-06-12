module sawtooth_wave(
  input  wire        clk,
  input  wire        rst_n,
  input  wire        en_48khz,
  input  wire [1:0]  freq_turn,
  output reg  [23:0] sawtooth_wave
);

  reg signed [23:0] step;

  always @(*) begin
    case(freq_turn)
      2'b00: step = 23'sd3200;
      2'b01: step = 23'sd6400;
      2'b10: step = 23'sd12800;
      2'b11: step = 23'sd256000;
      default: step = 23'sd256000;
    endcase 
  end 
  
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      sawtooth_wave <= 24'b0;
    end else begin
      if(en_48khz)
        sawtooth_wave <= step + sawtooth_wave;
    end 
  end 

endmodule 