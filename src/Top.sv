module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	input		 i_prev_random,
	output [3:0] o_random_out
);

// ===== States =====
parameter S_IDLE   = 3'b000; // idle state
parameter S_PROC_1 = 3'b001; // 0.0625 s
parameter S_PROC_2 = 3'b010; // 0.125 s
parameter S_PROC_3 = 3'b011; // 0.25 s
parameter S_PROC_4 = 3'b100; // 0.5s
parameter S_PROC_5 = 3'b101; // 1s

parameter MAX = 24'd10000000;	// #counter : 5000000 -> 1s
								// max = 2s

parameter MODE_1 = MAX >> 5;
parameter MODE_2 = MAX >> 4;
parameter MODE_3 = MAX >> 3;
parameter MODE_4 = MAX >> 2;
parameter MODE_5 = MAX >> 1;

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w, o_random_out_temp, o_random_out_prev;

// ===== Registers & Wires =====
logic [2:0]  state_r, state_w;
logic [23:0] mode_r, mode_w;
logic [23:0] counter_r, counter_w;
logic enable_signal;

// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

// ===== Combinational Circuits =====

always_comb begin
	// Default Values
	o_random_out_w = o_random_out_temp;
	state_w        = state_r;
	mode_w         = mode_r;
	counter_w      = counter_r + 1;

	// FSM
	case(state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
				o_random_out_w = o_random_out_r;
			end
		end

		S_PROC_1: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
			end else if (counter_r >= MAX) begin
				state_w = S_PROC_2;
				mode_w = MODE_2;
				counter_w = 24'd0;
			end 
		end

		S_PROC_2: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 24'd0;
			end else if (counter_r >= MAX) begin
				state_w = S_PROC_3;
				mode_w = MODE_3;
				counter_w = 24'd0;
			end
		end

		S_PROC_3: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 24'd0;
			end else if (counter_r >= MAX) begin
				state_w = S_PROC_4;
				mode_w = MODE_4;
				counter_w = 24'd0;
			end
		end

		S_PROC_4: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 24'd0;
			end else if (counter_r >= MAX) begin
				state_w = S_PROC_5;
				mode_w = MODE_5;
				counter_w = 24'd0;
			end
		end

		S_PROC_5: begin
			if (i_start) begin
				state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 24'd0;
			end else if (counter_r >= MAX) begin
				state_w = S_IDLE;
				mode_w = MODE_1;
				counter_w = 24'd0;
			end
		end
	endcase

	//LSFR
	enable_signal = (state_r!=S_IDLE)&&(counter_r%mode_r == 0);
end

//instance of random_LFSR
random_LFSR lfsr(.enable(enable_signal), .i_rst_n(i_rst_n), .o_random_out(o_random_out_temp));

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		o_random_out_r <= 4'd0;
		state_r        <= S_IDLE;
		mode_r         <= MODE_1;
		counter_r      <= 24'd0;
	end
	else begin
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
		mode_r         <= mode_w;
		counter_r      <= counter_w;
	end
end

endmodule

//random number generator
module random_LFSR( 
	input enable,
	input i_rst_n,
	output [3:0] o_random_out
);	

// ===== Registers & Wires =====
logic [3:0] rand_ff_w, rand_ff_r;

// ===== Output Assignments =====
assign o_random_out = rand_ff_r;

// ===== Combinational Circuits =====
always_comb begin
	// Default Values
	rand_ff_w = rand_ff_r;
end

// ===== Sequential Circuits =====
always_ff @(posedge enable or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		rand_ff_r <= 4'd3;
	end	

	else begin
		rand_ff_r[3] <= (rand_ff_w[0])^(rand_ff_w[3]);
		rand_ff_r[2] <= rand_ff_w[3];
		rand_ff_r[1] <= rand_ff_w[2];
		rand_ff_r[0] <= rand_ff_w[1];
	end
end

endmodule