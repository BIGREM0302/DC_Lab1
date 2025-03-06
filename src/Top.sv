module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	input		 i_prev_random,
	input        i_catch,
	output [3:0] o_random_out
);

// ===== States =====
parameter S_IDLE   = 3'b000; // idle state
parameter S_PROC_1 = 3'b001; // 0.0625 s
parameter S_PROC_2 = 3'b010; // 0.125 s
parameter S_PROC_3 = 3'b011; // 0.25 s
parameter S_PROC_4 = 3'b100; // 0.5s
parameter S_PROC_5 = 3'b101; // 1s
parameter S_PREV   = 3'b110; // call previous random number
parameter S_CATCH  = 3'b111; // catch number present now

parameter MAX = 27'd100000000;	// #counter : 50000000 -> 1s , max = 2s

parameter MODE_1 = MAX >> 5;
parameter MODE_2 = MAX >> 4;
parameter MODE_3 = MAX >> 3;
parameter MODE_4 = MAX >> 2;
parameter MODE_5 = MAX >> 1;

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w,o_random_out_temp;
logic [3:0] o_random_out_prev_r, o_random_out_prev_w;

// ===== Registers & Wires =====
logic [2:0]  state_r, state_w;
logic [2:0]  past_state_r, past_state_w;
logic [26:0] mode_r, mode_w;
logic [26:0] counter_r, counter_w;
logic enable_signal;


// ===== Output Assignments =====
assign o_random_out = (state_r == S_PREV)? o_random_out_prev_r:o_random_out_r;

// ===== Combinational Circuits =====

always_comb begin
	// Default Values
	o_random_out_w = o_random_out_r;
	o_random_out_prev_w = o_random_out_prev_r;
	state_w        = state_r;
	past_state_w =  past_state_r;
	mode_w         = mode_r;
	counter_w      = counter_r + 1;

	// FSM
	case(state_r)

		S_IDLE: begin
			if (i_start) begin
				state_w = S_PROC_1;
				past_state_w = S_PROC_1;
				mode_w = MODE_1;
				o_random_out_prev_w = o_random_out_temp;
				counter_w = 27'd0;
			end
			if (i_prev_random) begin
				state_w = S_PREV;
			end
		end

		S_PROC_1: begin
			if (i_prev_random) begin
				state_w = S_PREV;
			end
			else if (i_start) begin
				state_w = S_PROC_1;
				past_state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 27'd0;
			end else if (i_catch) begin
				state_w = S_CATCH;

			end else if (counter_r >= MAX) begin
				state_w = S_PROC_2;
				past_state_w = S_PROC_2;
				mode_w = MODE_2;
				counter_w = 27'd0;
			end 
		end

		S_PROC_2: begin
			if (i_prev_random) begin
				state_w = S_PREV;
			end
			else if (i_start) begin
				state_w = S_PROC_1;
				past_state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 27'd0;

			end else if (i_catch) begin
				state_w = S_CATCH;

			end else if (counter_r >= MAX) begin
				state_w = S_PROC_3;
				mode_w = MODE_3;
				past_state_w = S_PROC_3;
				counter_w = 27'd0;
			end
		end

		S_PROC_3: begin
			if (i_prev_random) begin
				state_w = S_PREV;
			end
			else if (i_start) begin
				state_w = S_PROC_1;
				past_state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 27'd0;
			end else if (i_catch) begin
				state_w = S_CATCH;

			end else if (counter_r >= MAX) begin
				state_w = S_PROC_4;
				mode_w = MODE_4;
				past_state_w = S_PROC_4;
				counter_w = 27'd0;
			end
		end

		S_PROC_4: begin
			if (i_prev_random) begin
				state_w = S_PREV;
			end
			else if (i_start) begin
				state_w = S_PROC_1;
				past_state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 27'd0;
			end else if (i_catch) begin
				state_w = S_CATCH;

			end else if (counter_r >= MAX) begin
				state_w = S_PROC_5;
				past_state_w = S_PROC_5;
				mode_w = MODE_5;
				counter_w = 27'd0;
			end
		end

		S_PROC_5: begin
			if (i_prev_random) begin
				state_w = S_PREV;
			end
			else if (i_start) begin
				state_w = S_PROC_1;
				past_state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 27'd0;
			end else if (i_catch) begin
				state_w = S_CATCH;

			end else if (counter_r >= MAX) begin
				state_w = S_IDLE;
				past_state_w = S_IDLE;
				mode_w = MODE_1;
				counter_w = 27'd0;
			end
		end

		S_PREV: begin
			if(i_prev_random) begin
				state_w = past_state_r; //直接回去剛剛的state裡面 繼續用剛剛數的結果	
				counter_w = counter_r;
			end 

			else if (i_catch) begin
				state_w = S_CATCH;
				counter_w = counter_r;
			end

			else if(i_start)begin
				state_w = S_PROC_1;
				past_state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 27'd0;
			end

			else begin
				counter_w = counter_r;
			end
			
		end

		S_CATCH: begin
			if(i_prev_random) begin
				state_w = S_PREV; //直接回去剛剛的state裡面 繼續用剛剛數的結果
				counter_w = counter_r;
			end 

			else if (i_catch) begin
				state_w = past_state_r;
				counter_w = counter_r;
			end

			else if(i_start)begin
				state_w = S_PROC_1;
				past_state_w = S_PROC_1;
				mode_w = MODE_1;
				counter_w = 27'd0;
			end

			else begin
				counter_w = counter_r;
			end
		end
	endcase

	//LSFR
	enable_signal = (state_r!=S_CATCH)&&(state_r!=S_IDLE)&&(state_r!=S_PREV)&&(counter_r%mode_r == 0); //改這裡的modulo就好
end

//instance of random_LFSR
random_LFSR lfsr(.enable(enable_signal), .i_rst_n(i_rst_n), .o_random_out(o_random_out_temp));

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		o_random_out_r <= 4'd0;
		o_random_out_prev_r <= 4'd0; //這裡可能要改
		state_r        <= S_IDLE;
		past_state_r <= S_IDLE;
		mode_r         <= MODE_1;
		counter_r      <= 27'd0;
	end
	else begin
		if(enable_signal == 1)begin
			o_random_out_r <= o_random_out_temp;
		end else begin
			o_random_out_r <= o_random_out_w;
		end
		o_random_out_prev_r <= o_random_out_prev_w;
		state_r        <= state_w;
		past_state_r <= past_state_w;
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

	else if(|rand_ff_r==0) begin
		rand_ff_r <= 4'd12;

	end

	else begin
		rand_ff_r[3] <= (rand_ff_w[0])^(rand_ff_w[3]);
		rand_ff_r[2] <= rand_ff_w[3];
		rand_ff_r[1] <= rand_ff_w[2];
		rand_ff_r[0] <= rand_ff_w[1];
	end
end

endmodule