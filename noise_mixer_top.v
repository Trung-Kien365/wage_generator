module noise_mixer_top (
    input  wire               clk,
    input  wire               rst_n,
    input  wire        [2:0]  sw_gain,
    input  wire signed [23:0] wave_in,   
    output wire signed [23:0] mixed_out   
);

    wire signed [23:0] raw_noise;
    wire signed [23:0] scaled_noise;

    lfsr u_lfsr (
        .clk(clk),
        .rst_n(rst_n),
        .noise_out(raw_noise)
    );

    gain_ctrl u_gain (
        .noise_in(raw_noise),
        .sw_gain(sw_gain),
        .noise_scaled(scaled_noise)
    );

    sat_mixer u_mixer (
        .wave_in(wave_in),
        .noise_in(scaled_noise),
        .mixed_out(mixed_out) 
    );

endmodule