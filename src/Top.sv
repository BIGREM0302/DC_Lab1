module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

// ===== States =====
parameter S_IDLE   = 2'b00;
parameter S_PROC_1 = 2'b01;
parameter S_PROC_2 = 2'b10;
parameter S_PROC_3 = 2'b11;

parameter MAX = 27'b111111111111111111111111111;

parameter MODE_1 = MAX >> 8;
parameter MODE_2 = MAX >> 5;
parameter MODE_3 = MAX >> 2;

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w;

// ===== Registers & Wires =====
logic [1:0]  state_r, state_w;
logic [26:0] mode_r, mode_w;
logic [26:0] counter_r, counter_w;

// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

// ===== Combinational Circuits =====

function [3:0] random_LFSR;
    input [3:0] lfsr_in;
    begin
        random_LFSR = (lfsr_in >> 1) ^ (-(lfsr_in & 1) & 4'b1011);
    end
endfunction


always_comb begin
	// Default Values
	o_random_out_w = o_random_out_r;
	state_w        = state_r;
	mode_w         = mode_r;
	counter_w      = counter_r + 1;

	if (counter_r % mode_r == 0) begin
		o_random_out_w = random_LSFR(o_random_out_r);
	end

	// FSM
	case(state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
				o_random_out_w = 4'd15;
			end
		end

		S_PROC_1: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
			end else if (counter_r >= MAX) begin
				state_w = S_PROC_2;
				mode_w = MODE_2;
				counter_w = 27'd0;
			end
		end

		S_PROC_2: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
			end else if (counter_r >= MAX) begin
				state_w = S_PROC_3;
				mode_w = MODE_3;
				counter_w = 27'd0;
			end
		end

		S_PROC_3: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
			end else if (counter_r >= MAX) begin
				state_w = S_IDLE;
				mode_w = MODE_1;
				counter_w = 27'd0;
			end
		end
	endcase
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		o_random_out_r <= 4'd0;
		state_r        <= S_IDLE;
		mode_r         <= MODE_1;
		counter_r      <= 27'd0;
	end
	else begin
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
		mode_r         <= mode_w;
		counter_r      <= counter_w;
	end
end

endmodule
