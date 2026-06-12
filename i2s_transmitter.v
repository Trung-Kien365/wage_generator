module i2s_transmitter(
  input wire        bclk,
  input wire        rst_n,
  input wire [23:0] digital_value,
  output wire       daclrc,
  output wire       dacdat
);

  wire serial_data;
  reg [ 4:0] value;
  reg        reverse;
  reg [23:0] shift_register_1;
  reg [23:0] shift_register_2;
  reg        load_value;

  always @(negedge bclk or negedge rst_n) begin
    if(!rst_n) begin
      value   <= 5'd0; 
      reverse <= 1'b0;   
    end else begin
      if(value == 31) begin
        value   <= 5'd0;
        reverse <= ~ reverse; 
      end else begin
        value   <= value + 1'b1;
      end 
    end 
  end 

  assign daclrc = reverse;
  assign serial_data = (daclrc) ? shift_register_1[23] : shift_register_2[23];
  assign dacdat = (value == 5'd0) ? 1'b0 : serial_data;
  
  always @(negedge bclk or negedge rst_n) begin
    if(!rst_n) begin
      shift_register_1 <= 0;
      shift_register_2 <= 0;
    end else begin
      if(load_value) begin
        shift_register_1 <= digital_value;
        shift_register_2 <= digital_value;
      end else begin
        if(value == 5'd0) begin
          shift_register_1 <= shift_register_1;
          shift_register_2 <= shift_register_2;
        end else begin
          if(daclrc) begin
            shift_register_1 <= {shift_register_1[22:0], 1'b0};
          end else begin
            shift_register_2 <= {shift_register_2[22:0], 1'b0};
          end
        end 
      end 
    end 
  end 

  always @(posedge bclk or negedge rst_n) begin
    if(!rst_n) begin
      load_value <= 1'b0;
    end else begin
      load_value <= (shift_register_1 == 24'b0 && shift_register_2 == 24'b0 && value == 5'b0);
    end 
  end 

endmodule