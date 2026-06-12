module fsm_i2c_controller(
  input  wire enable,
  input  wire rst_n,
  input  wire clk,
  output reg o_scl,
  inout wire o_sda
);

  wire        en_sda;
  reg         t_sda_o;
  reg         t_scl;
  reg         t_sda;    
  reg         div_clock;
  wire        end_state;
  wire        en_shift_1;
  wire        en_shift_2;
  wire        en_shift_3;
  wire        en_counter;
  reg  [ 3:0] cnt_2;
  reg  [ 7:0] cnt_1;
  wire [ 3:0] next_counter;
  reg  [ 3:0] data_counter;
  reg  [15:0] data;
  reg  [ 7:0] shift_register_1;
  reg  [ 7:0] shift_register_2;
  reg  [ 7:0] shift_register_3;
  reg  [ 3:0] next_state;
  reg  [ 3:0] state;
  reg  [ 3:0] select_state_1;
  reg  [ 3:0] select_state_2;
  reg  [ 3:0] select_state_3;
  wire [ 3:0] select_state_4;
  wire        start;
  wire        end_start;
  reg         sda;
  wire        clk_en;

  localparam [7:0] ADDRESS = 8'b00110100;
  
  // Register R15 reset Chip
  localparam [7:0] R15        = 8'h1E;
  localparam [7:0] RESET_CHIP = 8'h00;
  
  // Power on tắt tránh nois
  localparam [7:0] R6         = 8'h0C;
  localparam [7:0] POWER_CTRL = 8'h01;
  
  // Audio Interface I2C, 24 bit
  localparam [7:0] R7         = 8'h0E;
  localparam [7:0] AUDIO_INF  = 8'h0A;
  
  // Sampling fs = 48khz 
  localparam [7:0] R8         = 8'h10;
  localparam [7:0] SAMPLING   = 8'h00;
  
  // DAC enable analog path
  localparam [7:0] R4         = 8'h08;
  localparam [7:0] DAC_EN     = 8'h15;

  // Digital Audio Path
  localparam [7:0] R5         = 8'h0A; 
  localparam [7:0] UNMUTE     = 8'h00;
  
  // Right head out 
  localparam [7:0] R3         = 8'h06;
  localparam [7:0] RIGHT_OUT  = 8'h79;
  
  // Left head out 
  localparam [7:0] R2         = 8'h04;
  localparam [7:0] LEFT_OUT   = 8'h79;  
  
  // Active control
  localparam [7:0] R9         = 8'h12;
  localparam [7:0] ACTV_CTRL  = 8'h01;
  
  // Power on 
  localparam [7:0] POWER_ON   = 8'h07;
  
  localparam [3:0] IDLE       = 4'b0000;
  localparam [3:0] START      = 4'b0001;
  localparam [3:0] END_START  = 4'b0010;
  localparam [3:0] ADDR       = 4'b0011;
  localparam [3:0] ACK_1      = 4'b0100;
  localparam [3:0] DATA_1     = 4'b0101;
  localparam [3:0] ACK_2      = 4'b0110;
  localparam [3:0] DATA_2     = 4'b0111;  
  localparam [3:0] ACK_3      = 4'b1000;
  localparam [3:0] STOP       = 4'b1001;
  localparam [3:0] END        = 4'b1010;

  // Currrent state 
  wire state_transition_en;
  assign state_transition_en = (!en_counter) || (cnt_2 == 4'd7);

  // Cập nhật Current state 
  always @(posedge div_clock or negedge rst_n) begin
    if(!rst_n) begin
      state <= IDLE;
    end else if (enable) begin
      if (state_transition_en) begin
        state <= next_state; 
      end
    end else begin
      state <= IDLE;
    end 
  end
 
  // Next state
  always @(*) begin
    case(state)
      IDLE      : next_state = START;
      START     : next_state = END_START;
      END_START : next_state = ADDR;
      ADDR      : next_state = ACK_1;
      ACK_1     : next_state = select_state_1;
      DATA_1    : next_state = ACK_2;
      ACK_2     : next_state = select_state_2;
      DATA_2    : next_state = ACK_3;
      ACK_3     : next_state = select_state_3;
      STOP      : next_state = select_state_4;
      END       : next_state = END;
      default   : next_state = IDLE;
    endcase
  end 
    
  always @(posedge o_scl) begin
    if(o_sda == 1) begin
      select_state_1 <= IDLE;
      select_state_2 <= IDLE;
      select_state_3 <= IDLE;
    end else begin
      select_state_1 <= DATA_1;
      select_state_2 <= DATA_2;
      select_state_3 <= STOP;
    end
  end

  assign select_state_4 = (end_state) ? END : IDLE;

  // Output
  always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
      o_scl <= 1'b1;
      t_sda_o <= 1'b1;
    end else begin
      o_scl = t_scl;
      t_sda_o <= t_sda;
    end
  end 

  assign o_sda = (en_sda) ? 1'bz : t_sda_o;
  assign en_sda = (state == ACK_1 || state == ACK_2 || state == ACK_3);

  always @(*) begin
    case(state) 
      IDLE: begin
        t_scl = 1'b1;
        t_sda = 1'b1;
        end
        
      START: begin
        t_scl = 1'b1;
        t_sda = 0;
        end 

      END_START: begin
        t_scl = 0;
        t_sda = 0;
        end 
      
      ADDR: begin
        t_scl = div_clock;
        t_sda = sda;
        end 
        
      ACK_1: begin
        t_scl = div_clock;
        t_sda = sda;
        end 
      
      DATA_1: begin
        t_scl = div_clock;
        t_sda = sda;
        end
      
      ACK_2: begin
        t_scl = div_clock;
        t_sda = sda;
        end 
      
      DATA_2: begin
        t_scl = div_clock;
        t_sda = sda;
        end
      
      ACK_3: begin
        t_scl = div_clock;
        t_sda = sda;
        end
      
      STOP: begin
        t_scl = 1'b1;
        t_sda = 1'b0;
        end
        
      END: begin
        t_scl = 1'b1;
        t_sda = 1'b1;
        end
        
      default: begin
        t_scl = 1'b1;
        t_sda = 1'b1;
        end
    endcase
  end 
  
  always @(*) begin
    case(state)
      ADDR   : sda = shift_register_3[7];
      DATA_1 : sda = shift_register_1[7];
      DATA_2 : sda = shift_register_2[7];
      default: sda = 1'b1;
    endcase  
  end 

  // Shift left register
  always @(negedge en_shift_1 or negedge rst_n) begin
    if(!rst_n) begin 
      shift_register_1 <= 8'b0;
    end else if(!end_start) begin
      shift_register_1 <= {shift_register_1[6:0], 1'b0};
    end else begin
      shift_register_1 <= data[15:8];
    end   
  end

  always @(negedge en_shift_2 or negedge rst_n) begin
    if(!rst_n) begin 
      shift_register_2 <= 8'b0;
    end else if(!end_start) begin
      shift_register_2 <= {shift_register_2[6:0], 1'b0};
    end else begin
      shift_register_2 <= data[7:0];
    end   
  end

  always @(negedge en_shift_3 or negedge rst_n) begin
    if(!rst_n) begin 
      shift_register_3 <= {ADDRESS};
    end else if(!end_start) begin
      shift_register_3 <= {shift_register_3[6:0], 1'b0};
    end else begin
      shift_register_3 <= ADDRESS;
    end   
  end
  
  assign en_shift_1 = ((div_clock && (state == DATA_1)) || start);
  assign en_shift_2 = ((div_clock && (state == DATA_2)) || start);
  assign en_shift_3 = ((div_clock && (state == ADDR)) || start);

  // Data counter  
  assign start        = (state == START) ? 1'b1 : 1'b0;
  assign end_start    = (state == END_START) ? 1'b1 : 1'b0;
  assign next_counter = data_counter + 1'b1;
  assign end_state    = (data_counter == 10) ? 1'b1 : 1'b0;
  
  always @(negedge start or negedge rst_n) begin
    if(!rst_n) begin
      data_counter <= 4'b0;
    end else begin 
      data_counter <= next_counter;
    end 
  end 
  
  // Data memory
  always @(*) begin
    case (data_counter)
     4'b0000: data = {R15, RESET_CHIP};
     4'b0001: data = {R6, POWER_CTRL};
     4'b0010: data = {R7, AUDIO_INF};
     4'b0011: data = {R8, SAMPLING};
     4'b0100: data = {R4, DAC_EN};
     4'b0101: data = {R5, UNMUTE}; 
     4'b0110: data = {R3, RIGHT_OUT};
     4'b0111: data = {R2, LEFT_OUT};
     4'b1000: data = {R9, ACTV_CTRL};
     4'b1001: data = {R6, POWER_ON};
     default: data = {R15, RESET_CHIP};
    endcase
  end
    
  // f_div_128 clock
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      cnt_1 <= 8'd0;
    end else if(cnt_1 == 8'd85) begin
      cnt_1 <= 8'd0;
    end else begin
      cnt_1 <= cnt_1 + 8'd1;
    end 
  end 

  assign clk_en = (cnt_1 == 8'd0);

  always @(posedge clk_en or negedge rst_n) begin
    if(!rst_n) begin
      div_clock <= 1'b0;
    end else begin
      div_clock <= ~ div_clock;
    end 
  end 
  
  always @(posedge div_clock or negedge rst_n) begin
    if(!rst_n) begin
      cnt_2 <= 4'b0;
    end else if(!en_counter) begin
      cnt_2 <= 4'b0;      
    end else if(cnt_2 == 4'd7) begin
      cnt_2 <= 4'b0;
    end else begin
      cnt_2 <= cnt_2 + 1'b1;
    end   
  end
  
  assign en_counter = (state == ADDR || state == DATA_1 || state == DATA_2);
  
endmodule
