`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:28:24 02/09/2015 
// Design Name: 
// Module Name:    clock 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clock(
    input clk,
    output clk_S,
    output prev_clk_S
    );

   reg [3:0]    clk_S = {4'b0000};		//1hz - 2 Hz - blink (4Hz) - fast (100Hz)
   reg [3:0]    prev_clk_S = {4'b0000};
   reg [31:0]   counter = 0;//= {32'b00000000000000000000000000000000};
   
   always @ (posedge clk)
	begin
		counter = counter + 1;
		if (counter % (50 * 1024 * 1024) == 0)
			begin
				//counter = 0;
				if (clk_S[0] == 0)
					begin
						prev_clk_S[0] = 0;
						clk_S[0] = 1;
					end
				else
					begin
						prev_clk_S[0] = 1;
						clk_S[0] = 0;
					end
				if (clk_S[1] == 0)
					begin
						prev_clk_S[1] = 0;
						clk_S[1] = 1;
					end
				else
					begin
						prev_clk_S[1] = 1;
						clk_S[1] = 0;
					end
			end
		else if (counter % (25 * 1024 * 1024) == 0)
			begin
				if (clk_S[1] == 0)
					begin
						prev_clk_S[1] = 0;
						clk_S[1] = 1;
					end
				else
					begin
						prev_clk_S[1] = 1;
						clk_S[1] = 0;
					end
			end
		else 
			begin
				prev_clk_S[0] = clk_S[0];
				prev_clk_S[1] = clk_S[1];
			end
		if (counter % (25 * 256 * 1024) == 0)
			begin
				if (clk_S[2] == 0)
					begin
						prev_clk_S[2] = 0;
						clk_S[2] = 1;
					end
				else
					begin
						prev_clk_S[2] = 1;
						clk_S[2] = 0;
					end
			end
		else
			begin
				prev_clk_S[2] = clk_S[2];
			end
		if (counter % (71117) == 0)
			begin
				if (clk_S[3] == 0)
					begin
						prev_clk_S[3] = 0;
						clk_S[3] = 1;
					end
				else
					begin
						prev_clk_S[3] = 1;
						clk_S[3] = 0;
					end
			end
		else
			begin
				prev_clk_S[3] = clk_S[3];
			end
	end
	
	/*reg[15:0] sec_count;
	int minutes;
	int seconds;
		
	always @ (posedge clk)
		begin
			if (prev_clk_S[0] == 0 && clk_S[0] == 1)
				begin
					if (sec_count != 6000)
						begin
							sec_count = sec_count + 1;
						end
					else
						begin
							sec_count = 0;
						end
				end
			minutes = sec_count / 60;
			seconds = sec_count % 60;
		end*/
endmodule
