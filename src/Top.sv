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

parameter MAX = 27'b1111111111111111111111111111;

parameter MODE_1 = MAX >> 2;
parameter MODE_2 = MAX >> 5;
parameter MODE_3 = MAX >> 8;

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w;

// ===== Registers & Wires =====
logic [1:0]  state_r, state_w;
logic [26:0] mode_r, mode_w;
logic [26:0] counter;

// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

// ===== Combinational Circuits =====
always_comb begin
	// Default Values
	o_random_out_w = o_random_out_r;
	state_w        = state_r;
	mode_w         = mode_r;

	if (counter % mode_r == 0) begin
		o_random_out_w = random();
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
			end else if (counter == MAX) begin
				state_w = S_PROC_2;
				mode_w = MODE_2;
			end
		end

		S_PROC_2: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
			end else if (counter == MAX) begin
				state_w = S_PROC_3;
				mode_w = MODE_3;
			end
		end

		S_PROC_3: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
			end else if (counter == MAX) begin
				state_w = S_IDLE;
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
		counter <= 0;
	end
	else begin
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
		mode_r         <= mode_w;
		counter        <= counter + 1;
	end
end

endmodule