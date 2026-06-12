module lfsr(
    input  wire        clk,
    input  wire        rst_n,
    output reg  [23:0] noise_out
);
    reg  [23:0] lfsr_reg;
    wire        feedback;

    assign feedback = lfsr_reg[23] ^ lfsr_reg[22] ^ lfsr_reg[21] ^ lfsr_reg[16];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_reg  <= 24'hACE123;
            noise_out <= 24'd0;
        end else begin
            lfsr_reg  <= {lfsr_reg[22:0], feedback};
            noise_out <= lfsr_reg;
        end
    end
endmodule

module gain_ctrl (
    input  wire signed [23:0] noise_in,
    input  wire        [2:0]  sw_gain,
    output reg  signed [23:0] noise_scaled
);
    always @(*) begin
        case (sw_gain)
            3'b000: noise_scaled = noise_in >>> 7;
            3'b001: noise_scaled = noise_in >>> 6;
            3'b010: noise_scaled = noise_in >>> 5;
            3'b011: noise_scaled = noise_in >>> 4;
            3'b100: noise_scaled = noise_in >>> 3;
            3'b101: noise_scaled = noise_in >>> 2;
            3'b110: noise_scaled = noise_in >>> 1;
            3'b111: noise_scaled = noise_in;
            default: noise_scaled = 24'd0;
        endcase
    end
endmodule

module sat_mixer (
    input  wire signed [23:0] wave_in,
    input  wire signed [23:0] noise_in,
    output reg  signed [23:0] mixed_out
);
    wire signed [24:0] sum = {wave_in[23], wave_in} + {noise_in[23], noise_in};

    always @(*) begin
        if      (sum[24] == 1'b0 && sum[23] == 1'b1) mixed_out = 24'sh7FFFFF;
        else if (sum[24] == 1'b1 && sum[23] == 1'b0) mixed_out = 24'sh800000;
        else                                          mixed_out = sum[23:0];
    end
endmodule