module nexys3 (/*AUTOARG*/
   // Outputs
   RsTx, Led, seg, an, clk_S, prev_clk_S,
   // Inputs
   RsRx, sw, btnS, btnR, btnU, clk
   );

`include "seq_definitions.v"
   
   // USB-UART
   input        RsRx;
   output       RsTx;

   // Misc.
   input  [7:0] sw;
   output [7:0] Led;
   output reg [7:0] seg;
   output reg [3:0] an;
   
   input        btnS;                 // Pause/Unpause game
   input        btnR;                 // 
   input        btnU;                 // Show high score
   
   // Logic
   input        clk;                  // 100MHz
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [seq_dp_width-1:0] seq_tx_data;         // From seq_ of seq.v
   wire                 seq_tx_valid;           // From seq_ of seq.v
   wire [7:0]           uart_rx_data;           // From uart_top_ of uart_top.v
   wire                 uart_rx_valid;          // From uart_top_ of uart_top.v
   wire                 uart_tx_busy;           // From uart_top_ of uart_top.v
   // End of automatics
   
   wire        rst;
   wire        arst_i;
   wire [17:0] clk_dv_inc;
   

   reg [1:0]   arst_ff;
   reg [16:0]  clk_dv;
   reg         clk_en;
   reg         clk_en_d;
      
   reg [7:0]   inst_wd;
   reg         inst_vld;
   reg [2:0]   step_d;

   reg [7:0]   inst_cnt;
   reg [7:0]   moles = 0;
   reg [7:0]   switchs;
   integer     score = 0;
   integer     moleCount = 0;

   reg [2:0]   mole1 = 0;
   reg [2:0]   mole2 = 0;
   reg [2:0]   mole3 = 0;
   reg [2:0]   mole4 = 0;
   reg [2:0]   toDeleteMole = 0;
   
   reg [1:0]   tPAUSE = {2'b00};
   reg [1:0]   tRESET = {2'b00};


   output [3:0]   clk_S;
   output [3:0]   prev_clk_S;
   
   integer sec_count = 30;
   integer fun_count = 0;
   reg     bGameMode = 0;
   reg	   bPAUSE    = 0;
   integer random = 1;
	//Button debounce


	// Countdown timer
   always @ (posedge clk)
   
	begin
					//tPAUSE [1] IS THE CURRENT
			//tPAUSE [0] IS THE PREVIOUS
			//DO NOT CHANGE THE FUCKING SYMANTECS
			//kthx
	if (clk_S[3] == 1 && prev_clk_S[3] == 0)
	begin
	
		tPAUSE[0] = tPAUSE[1];
		tPAUSE[1] = btnS;
		tRESET[0] = tRESET[1];
		tRESET[1] = btnR;
			//check for {2b'01}
		if(tPAUSE == 1)
		begin
			if(bGameMode)
				begin
					bPAUSE = !bPAUSE;
				end
			else
				begin
					bGameMode = 1;
					bPAUSE = 0;
				end
		end
		if(tRESET == 1)
		begin
			bGameMode = 0;
			moles = 0;
			moleCount = 0;
			sec_count = 30;
			//Led = moles;

		end
	end
	if (clk_S[0] == 1 && prev_clk_S[0] == 0)
			begin
				if (bGameMode == 1 && !bPAUSE)
					begin
						sec_count = sec_count - 1;
						if (sec_count == 0)
							begin
								sec_count = 30;
								bGameMode = 0;
							end
					end
			end

		random = random + clk_S[0] + clk_S[3];
//May God have mercy on our Souls for this shit code
		if(bPAUSE)
			begin
			//do nothing lol
			end
		//generate new mole
		else if(prev_clk_S[1] == 0 && clk_S[1] == 1 && bGameMode)
			begin
				//random = $unsigned($random % 8);
				random = random % 8;
				if(random == mole1 || random == mole2 || random == mole3 || random == mole4)
					begin
						random = random+1;
						if(random == 8)
						begin
							random = 0;
						end
					end
				if(random == mole1 || random == mole2 || random == mole3 || random == mole4)
					begin
						random = random+1;
						if(random == 8)
						begin
							random = 0;
						end
					end
				if(random == mole1 || random == mole2 || random == mole3 || random == mole4)
					begin
						random = random+1;
						if(random == 8)
						begin
							random = 0;
						end
					end
				if(random == mole1 || random == mole2 || random == mole3 || random == mole4)
					begin
						random = random+1;
						if(random == 8)
						begin
							random = 0;
						end
					end
				

				// we now have a valid position to put a mole
				// use the mole arrayto populate LEDs
				toDeleteMole = mole4;
				mole4 = mole3;
				mole3 = mole2;
				mole2 = mole1;
				mole1 = random;
				moles[mole1] = 1;
				moleCount = moleCount + 1;
			end
	//end Generate new Mole
	//Delete mole if moleCount == 5;
		if(prev_clk_S[1] == 0 && clk_S[1] == 1 && bGameMode)
			begin
				if(moleCount >= 5)
					begin
						moles[toDeleteMole]  = 0;
						moleCount = moleCount - 1;
					end
			end
	//end delete Mole
		end	
	
	
	
	integer act_dig = 0;
	integer act_val = 0;
	
	
	assign Led[7:0] = moles[7:0];//populate the LEDs with the moles
	//Visual Module
	always @ (posedge clk)
	begin
		if(bGameMode) //Game has started
		begin
			if(prev_clk_S[3] == 0 && clk_S[3] == 1) //fast clock
				begin
					
					act_dig = act_dig+1;
					if(act_dig == 4)
						begin
							act_dig = 0;
						end
					if(act_dig == 0)
						begin
							act_val = sec_count/10;
							an[0] = 1;
							an[1] = 1;
							an[2] = 1;
							an[3] = 0;
						end
					else if(act_dig == 1)
						begin
							act_val = sec_count%10;
							an[0] = 1;
							an[1] = 1;
							an[2] = 0;
							an[3] = 1;
						end
					else if(act_dig == 2)
						begin
							act_val = 0;
							an[0] = 1;
							an[1] = 0;
							an[2] = 1;
							an[3] = 1;
						end
					else if(act_dig == 3)
						begin
							act_val = 0;
							an[0] = 0;
							an[1] = 1;
							an[2] = 1;
							an[3] = 1;
						end
						
					if(act_val == 0)
						begin
							seg[0] = 0;
							seg[1] = 0;
							seg[2] = 0;
							seg[3] = 0;
							seg[4] = 0;
							seg[5] = 0;
							seg[6] = 1;
							seg[7] = 1;
							
						end
					else if(act_val == 1)
						begin
							seg[0] = 1;
							seg[1] = 0;
							seg[2] = 0;
							seg[3] = 1;
							seg[4] = 1;
							seg[5] = 1;
							seg[6] = 1;
							seg[7] = 1;
						end
					else if(act_val == 2)
						begin
							seg[0] = 0;
							seg[1] = 0;
							seg[2] = 1;
							seg[3] = 0;
							seg[4] = 0;
							seg[5] = 1;
							seg[6] = 0;
							seg[7] = 1;
						end
					else if(act_val == 3)
						begin
							seg[0] = 0;
							seg[1] = 0;
							seg[2] = 0;
							seg[3] = 0;
							seg[4] = 1;
							seg[5] = 1;
							seg[6] = 0;
							seg[7] = 1;
						end
					else if(act_val == 4)
						begin
							seg[0] = 1;
							seg[1] = 0;
							seg[2] = 0;
							seg[3] = 1;
							seg[4] = 1;
							seg[5] = 0;
							seg[6] = 0;
							seg[7] = 1;
						end
					else if(act_val == 5)
						begin
							seg[0] = 0;
							seg[1] = 1;
							seg[2] = 0;
							seg[3] = 0;
							seg[4] = 1;
							seg[5] = 0;
							seg[6] = 0;
							seg[7] = 1;
						end
					else if(act_val == 6)
						begin
							seg[0] = 0;
							seg[1] = 1;
							seg[2] = 0;
							seg[3] = 0;
							seg[4] = 0;
							seg[5] = 0;
							seg[6] = 0;
							seg[7] = 1;
						end
					else if(act_val == 7)
						begin
							seg[0] = 0;
							seg[1] = 0;
							seg[2] = 0;
							seg[3] = 1;
							seg[4] = 1;
							seg[5] = 0;
							seg[6] = 1;
							seg[7] = 1;
						end
					else if(act_val == 8)
						begin
							seg[0] = 0;
							seg[1] = 0;
							seg[2] = 0;
							seg[3] = 0;
							seg[4] = 0;
							seg[5] = 0;
							seg[6] = 0;
							seg[7] = 1;
						end
					else if(act_val == 9)
						begin
							seg[0] = 0;
							seg[1] = 0;
							seg[2] = 0;
							seg[3] = 0;
							seg[4] = 1;
							seg[5] = 0;
							seg[6] = 0;
							seg[7] = 1;
						end
			end
		end
		else	//Game mode not on, Fun animation!
			begin
				if(prev_clk_S[2] == 0 && clk_S[2] == 1) //4Hz
					begin
						fun_count = fun_count +1;
						if(fun_count >= 8)
							begin
								fun_count = 0;
							end
					if(fun_count == 0)
						begin
							seg[0] = 0;
							seg[1] = 1;
							seg[2] = 1;
							seg[3] = 1;
							seg[4] = 1;
							seg[5] = 1;
							seg[6] = 1;
							seg[7] = 1;
						end
					else if(fun_count == 1)
						begin
							seg[0] = 1;
							seg[1] = 0;
							seg[2] = 1;
							seg[3] = 1;
							seg[4] = 1;
							seg[5] = 1;
							seg[6] = 1;
							seg[7] = 1;
						end
					else if(fun_count == 2 || fun_count == 6)
						begin
							seg[0] = 1;
							seg[1] = 1;
							seg[2] = 1;
							seg[3] = 1;
							seg[4] = 1;
							seg[5] = 1;
							seg[6] = 0;
							seg[7] = 1;
						end
					else if(fun_count == 3)
						begin
							seg[0] = 1;
							seg[1] = 1;
							seg[2] = 1;
							seg[3] = 1;
							seg[4] = 0;
							seg[5] = 1;
							seg[6] = 1;
							seg[7] = 1;
						end	
					else if(fun_count == 4)
						begin
							seg[0] = 1;
							seg[1] = 1;
							seg[2] = 1;
							seg[3] = 0;
							seg[4] = 1;
							seg[5] = 1;
							seg[6] = 1;
							seg[7] = 1;
						end
					else if(fun_count == 5)
						begin
							seg[0] = 1;
							seg[1] = 1;
							seg[2] = 0;
							seg[3] = 1;
							seg[4] = 1;
							seg[5] = 1;
							seg[6] = 1;
							seg[7] = 1;
						end
					else if(fun_count == 7)
						begin
							seg[0] = 1;
							seg[1] = 1;
							seg[2] = 1;
							seg[3] = 1;
							seg[4] = 1;
							seg[5] = 0;
							seg[6] = 1;
							seg[7] = 1;
						end
					end
					if(prev_clk_S[3] == 0 && clk_S[3] == 1)
					begin
					act_dig = act_dig+1;
					if(act_dig == 4)
						begin
							act_dig = 0;
						end
					if(act_dig == 0)
						begin
							an[0] = 1;
							an[1] = 1;
							an[2] = 1;
							an[3] = 0;
						end
					else if(act_dig == 1)
						begin
							an[0] = 1;
							an[1] = 1;
							an[2] = 0;
							an[3] = 1;
						end
					else if(act_dig == 2)
						begin
							an[0] = 1;
							an[1] = 0;
							an[2] = 1;
							an[3] = 1;
						end
					else if(act_dig == 3)
						begin
							an[0] = 0;
							an[1] = 1;
							an[2] = 1;
							an[3] = 1;
						end
					end
			end
	end
   
   
   
   // ===========================================================================
   // Sequencer
   // ===========================================================================

   seq seq_ (// Outputs
             .o_tx_data                 (seq_tx_data[seq_dp_width-1:0]),
             .o_tx_valid                (seq_tx_valid),
             // Inputs
             .i_tx_busy                 (uart_tx_busy),
             .i_inst                    (inst_wd[seq_in_width-1:0]),
             .i_inst_valid              (inst_vld),
             /*AUTOINST*/
             // Inputs
             .clk                       (clk),
             .rst                       (rst));
   
   // 
   // ===========================================================================
   // UART controller
   // ===========================================================================

   uart_top uart_top_ (// Outputs
                       .o_tx            (RsTx),
                       .o_tx_busy       (uart_tx_busy),
                       .o_rx_data       (uart_rx_data[7:0]),
                       .o_rx_valid      (uart_rx_valid),
                       // Inputs
                       .i_rx            (RsRx),
                       .i_tx_data       (seq_tx_data[seq_dp_width-1:0]),
                       .i_tx_stb        (seq_tx_valid),
                       /*AUTOINST*/
                       // Inputs
                       .clk             (clk),
                       .rst             (rst));
					   
	clock c1 (.clk(clk), .clk_S(clk_S[3:0]), .prev_clk_S(prev_clk_S[3:0]));
   
endmodule // nexys3
// Local Variables:
// verilog-library-flags:("-f ../input.vc")
// End:
