module triangle_wave(
  input  wire              clk,
  input  wire              rst_n,
  input  wire              en_48khz,
  input  wire       [1:0]  freq_turn,
  output wire       [23:0] triangle_wave
);
  
  localparam signed [23:0] MAX = 24'd8388607;
  localparam signed [23:0] MIN = 24'h800000;
  
  localparam [1:0] START = 2'b00;
  localparam [1:0] ADD   = 2'b01;
  localparam [1:0] SUB   = 2'b10;
  
  reg signed [24:0] next_counter;
  reg signed [24:0] t_counter;
  reg signed [24:0] counter;
  reg signed [23:0] step;

  reg clr_counter;
  reg en_counter;
  reg control;

  reg [1:0] state;
  reg [1:0] next_state;

  wire lt_max;
  wire gt_min;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      counter <= 23'd0;
      state <= START;
    end else begin
      if(clr_counter) begin
        counter <= 23'd0;
      end else begin
        if(en_counter) begin
            if(en_48khz) begin
              if(!control)
                counter = t_counter + step;
              else 
                counter = t_counter - step;
            end
        end 
      end
      state <= next_state;
    end 
  end

  always @(*) begin
    case(freq_turn)
      2'b00: step = 23'sd3200;
      2'b01: step = 23'sd6400;
      2'b10: step = 23'sd12800;
      2'b11: step = 23'sd300000;
      default: step = 23'sd300000;
    endcase 
  end 

  assign lt_max = (counter < MAX);
  assign gt_min = (counter > MIN);
  assign triangle_wave = t_counter;

  always @(*) begin
    case(state)
      START:   next_state = ADD;
      ADD:     next_state = (lt_max) ? ADD : SUB;
      SUB:     next_state = (gt_min) ? SUB : ADD;
      default: next_state = START;
    endcase 
  end

  always @(*) begin
    case(state)
      START: begin
        en_counter = 0;
        clr_counter = 1;
        control = 0;
      end 

      ADD: begin
        en_counter = 1;
        clr_counter = 0;
        control = 0;
      end   

      SUB: begin
        en_counter = 1;
        clr_counter = 0;
        control = 1;
      end      

      default: begin
        en_counter = 0;
        clr_counter = 1;
        control = 0;
      end 
    endcase 
  end 

  always @(*) begin
    if(counter > MAX) begin
      t_counter = MAX;
    end else if(counter < MIN) begin 
      t_counter = MIN;
    end else begin
      t_counter = counter;
    end
  end

endmodule