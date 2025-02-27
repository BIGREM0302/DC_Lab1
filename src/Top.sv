module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

// please check out the working example in lab1 README (or Top_exmaple.sv) first
// ===== States =====
parameter S_IDLE = 3'd0;
parameter S_HIGH_1 = 3'd1;
parameter S_FREQ_2 = 3'd2;
parameter S_FREQ_3 = 3'd3;
parameter S_FREQ_4 = 3'd4;
parameter S_FREQ_5 = 3'd5;
parameter S_FREQ_6 = 3'd6;
parameter S_FREQ_7 = 3'd7;
parameter S_FREQ_8 = 3'd8;

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w;
logic o_clk_rand, o_clk_crtl;

// ===== Registers & Wires =====
logic state_r, state_w, ,[3:0] mode; 

// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

// ===== Combinational Circuits =====
always_comb begin
	// Default Values
	o_random_out_w = o_random_out_r;
	state_w        = state_r;

	// FSM
	case(state_r)

	S_IDLE: begin
		if (i_start) begin
			state_w = S_HIGH_1;
			mode = 3'd0
		end
	end

	S_HIGH_1: begin
		if (i_start) begin
			state_w = (i_start) ? S_FREQ_2 : S_HIGH_1;
			mode = 3'd1;
		end
	end

	S_FREQ_2: begin
		if (i_start) begin
			state_w = (i_start) ? S_FREQ_3 : S_FREQ_2;
			mode = 3'd2;
		end
	end

	S_FREQ_3: begin
		if (i_start) begin
			state_w = (i_start) ? S_FREQ_4 : S_FREQ_3;
			mode = 3'd3;
		end
	end

	S_FREQ_4: begin
		if (i_start) begin
			state_w = (i_start) ? S_FREQ_5 : S_FREQ_4;
			mode = 3'd4;
		end
	end

	S_FREQ_5: begin
		if (i_start) begin
			state_w = (i_start) ? S_FREQ_6 : S_FREQ_5;
			mode = 3'd5;
		end
	end

	S_FREQ_6: begin
		if (i_start) begin
			state_w = (i_start) ? S_FREQ_7 : S_FREQ_6;
			mode = 3'd6;
		end
	end

	S_FREQ_7: begin
		if (i_start) begin
			state_w = (i_start) ? S_FREQ_8 : S_FREQ_7;
			mode = 3'd7;
		end
	end
	
	S_FREQ_8: begin
		if (i_start) begin
			state_w = (i_start) ? S_IDLE: S_FREQ_8;
			mode = 3'd8;
		end
	end

	endcase

	//random number
	counter c1(i_clk,mode,o_clk_rand,o_clk_crtl)
	random_generator r1(o_random_out_w,)
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		o_random_out_r <= 4'd0;
		state_r        <= S_IDLE;
	end
	else begin
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
	end
end

endmodule



module random_generator(
	input        i_clk,
	output [3:0] o_random_out
);



endmodule



module counter(
	input        i_clk,
	input        mode,
	output 		 o_clk_rand
	output		 o_clk_crtl
);



endmodule