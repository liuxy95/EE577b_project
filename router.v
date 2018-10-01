module router(clk,reset,polarity,cwsi,cwri,cwdi,ccwsi,ccwri,ccwdi,pesi,peri,pedi,
cwso,cwro,cwdo,ccwso,ccwro,ccwdo,peso,pero,pedo);
parameter	ODD = 0,
			EVEN = 1;
input clk,reset;
input cwsi,ccwsi,pesi,cwro,ccwro,pero;
input[63:0] cwdi,ccwdi,pedi;
output polarity,cwso,ccwso,peso,cwri,ccwri,peri;
output[63:0] cwdo,ccwdo,pedo;
reg polarity;
reg cwri,ccwri,peri;
//cwso,ccwso,peso,cwri,ccwri,peri;
//reg[63:0] cwdo,ccwdo,pedo;

wire nclk;

reg cw_reg_odd_en,cw_reg_even_en;
reg ccw_reg_odd_en,ccw_reg_even_en;
reg pe_reg_odd_en,pe_reg_even_en;
wire[63:0] cw_reg_odd_Q,cw_reg_even_Q;
wire[63:0] ccw_reg_odd_Q,ccw_reg_even_Q;
wire[63:0] pe_reg_odd_Q,pe_reg_even_Q; //the output of input register
wire cwo_reg_odd_en,cwo_reg_even_en;
wire ccwo_reg_odd_en,ccwo_reg_even_en;
wire peo_reg_odd_en,peo_reg_even_en;
wire[63:0] cwo_reg_odd_D,cwo_reg_even_D;
wire[63:0] ccwo_reg_odd_D,ccwo_reg_even_D;
wire[63:0] peo_reg_odd_D,peo_reg_even_D;

reg[63:0] cwdo_odd,ccwdo_odd,pedo_odd;
reg[63:0] cwdo_even,ccwdo_even,pedo_even;

reg cwri_odd,cwri_even,ccwri_odd,ccwri_even,peri_odd,peri_even;
reg[1:0] cwi_reg_full,cwo_reg_full,ccwi_reg_full,ccwo_reg_full,pei_reg_full,peo_reg_full;// reg full or not, 0 is odd, 1 is even
reg[1:0] state_cw_odd,state_ccw_odd,state_pe_odd;
reg[1:0] state_cw_even,state_ccw_even,state_pe_even;

wire[1:0] grant_cw,grant_ccw,grant_pe;
reg[1:0] req_cw,req_ccw,req_pe;
//////// 6 64-bit input register ///////////
reg_64bit	cwi_reg_odd(clk,reset,cw_reg_odd_en,cwdi,cw_reg_odd_Q); 
reg_64bit	cwi_reg_even(clk,reset,cw_reg_even_en,cwdi,cw_reg_even_Q);
reg_64bit	ccwi_reg_odd(clk,reset,ccw_reg_odd_en,ccwdi,ccw_reg_odd_Q);
reg_64bit	ccwi_reg_even(clk,reset,ccw_reg_even_en,ccwdi,ccw_reg_even_Q);
reg_64bit	pei_reg_odd(clk,reset,pe_reg_odd_en,pedi,pe_reg_odd_Q);
reg_64bit	pei_reg_even(clk,reset,pe_reg_even_en,pedi,pe_reg_even_Q);
//////////// output register /////////////////
/*
reg_64bit	cwo_reg_odd(clk,reset,cwo_reg_odd_en,cwo_reg_odd_D,cwdo_odd); 
reg_64bit	cwo_reg_even(clk,reset,cwo_reg_even_en,cwo_reg_even_D,cwdo_even);
reg_64bit	ccwo_reg_odd(clk,reset,ccwo_reg_odd_en,ccwo_reg_odd_D,ccwdo_odd);
reg_64bit	ccwo_reg_even(clk,reset,ccwo_reg_even_en,ccwo_reg_even_D,ccwdo_even);
reg_64bit	peo_reg_odd(clk,reset,peo_reg_odd_en,peo_reg_odd_D,pedo_odd);
reg_64bit	peo_reg_even(clk,reset,peo_reg_even_en,peo_reg_even_D,pedo_even);*/

assign nclk=~clk;

arbiter_LRU2	arbiter_cw(grant_cw,req_cw,nclk,reset);
arbiter_LRU2	arbiter_ccw(grant_ccw,req_ccw,nclk,reset);
arbiter_LRU2	arbiter_pe(grant_pe,req_pe,nclk,reset);

always begin
	if(polarity==1'b0) begin
		req_cw[0] = cwi_reg_full[ODD] && ~cwo_reg_full[ODD];
		req_cw[1] = pei_reg_full[ODD] && ~cwo_reg_full[ODD];
	end
	else begin
		req_cw[0] = cwi_reg_full[EVEN] && ~cwo_reg_full[EVEN];
		req_cw[1] = pei_reg_full[EVEN] && ~cwo_reg_full[EVEN];
	end
end

always begin
	if(polarity==1'b0) begin
		req_ccw[0] = ccwi_reg_full[ODD] && ~ccwo_reg_full[ODD];
		req_ccw[1] = pei_reg_full[ODD] && ~ccwo_reg_full[ODD];
	end
	else begin
		req_ccw[0] = ccwi_reg_full[EVEN] && ~ccwo_reg_full[EVEN];
		req_ccw[1] = pei_reg_full[EVEN] && ~ccwo_reg_full[EVEN];
	end
end

always begin
	if(polarity==1'b0) begin
		req_pe[0] = cwi_reg_full[ODD] && ~peo_reg_full[ODD];
		req_pe[1] = ccwi_reg_full[ODD] && ~peo_reg_full[ODD];
	end
	else begin
		req_pe[0] = cwi_reg_full[EVEN] && ~peo_reg_full[EVEN];
		req_pe[1] = ccwi_reg_full[EVEN] && ~peo_reg_full[EVEN];
	end
end

assign cwdo = polarity ? cwdo_even : cwdo_odd;
assign ccwdo = polarity ? ccwdo_even : ccwdo_odd;
assign pedo = polarity ? pedo_even : pedo_odd;

assign cwso = polarity ? cwo_reg_full[EVEN] :cwo_reg_full[ODD];
assign ccwso = polarity ? ccwo_reg_full[EVEN] :ccwo_reg_full[ODD];
assign peso = polarity ? peo_reg_full[EVEN] :peo_reg_full[ODD];

///////////////////////////////////////////////////////////////////////////
always @(posedge clk)  // state machine for cw input odd channel
begin
	if(reset) begin
		cwi_reg_full <= 2'b00;
		cwo_reg_full <= 2'b00;
		ccwi_reg_full <= 2'b00;
		ccwo_reg_full <= 2'b00;
		pei_reg_full <= 2'b00;
		peo_reg_full <= 2'b00;
		polarity <= 1'b0;
	end
	else
		polarity<=~polarity;
	
	cwri <= polarity ? ~cwi_reg_full[EVEN] : ~cwi_reg_full[ODD]; //input register is ready to receive when it is not full
	ccwri <= polarity ? ~ccwi_reg_full[EVEN] : ~ccwi_reg_full[ODD];
	peri <= polarity ? ~pei_reg_full[EVEN] : ~pei_reg_full[ODD];
	
	cw_reg_odd_en <= ~cwi_reg_full[ODD] && ~polarity && cwsi; // input register for cw odd channel would be enabled when
													  // the register is not full and polarity equals to 0, and cwsi=1
	ccw_reg_odd_en <= ~ccwi_reg_full[ODD] && ~polarity && ccwsi;
	pe_reg_odd_en <= ~pei_reg_full[ODD] && ~polarity && pesi;
	
	cw_reg_even_en <= ~cwi_reg_full[EVEN] && polarity && cwsi;
	ccw_reg_even_en <= ~ccwi_reg_full[EVEN] && polarity && ccwsi;
	pe_reg_even_en <= ~pei_reg_full[EVEN] && polarity && pesi;
	
	if(polarity) begin  // set output register full flag to 0.
		if(cwo_reg_full[EVEN]==1'b1 && cwro==1'b1)
			cwo_reg_full[EVEN]<=1'b0;
		if(ccwo_reg_full[EVEN]==1'b1 && ccwro==1'b1)
			ccwo_reg_full[EVEN]<=1'b0;
		if(peo_reg_full[EVEN]==1'b1 && pero==1'b1)
			peo_reg_full[EVEN]<=1'b0;
	end
	else begin
		if(cwo_reg_full[ODD]==1'b1 && cwro==1'b1)
			cwo_reg_full[ODD]<=1'b0;
		if(ccwo_reg_full[ODD]==1'b1 && ccwro==1'b1)
			ccwo_reg_full[ODD]<=1'b0;
		if(peo_reg_full[ODD]==1'b1 && pero==1'b1)
			peo_reg_full[ODD]<=1'b0;
	end
	
	if(reset)
		state_cw_odd<=2'b00; // enter idle state
	else begin
		case(state_cw_odd)
			2'b00: begin
				if(cwsi==1'b1 && cwri==1'b1 && polarity==1'b0) begin
					state_cw_odd<=2'b01;
					cwi_reg_full[ODD]<=1'b1;
				end
			end
			2'b01: begin
				if(cw_reg_odd_Q[55:48]==8'h00 && peo_reg_full[ODD]==1'b0 && grant_pe[0]==1'b1) 
				begin
					state_cw_odd<=2'b10;
					peo_reg_full[ODD]<=1'b1;
					cwi_reg_full[ODD]<=1'b0;
					pedo_odd <= cw_reg_odd_Q;
				end
				else if(cw_reg_odd_Q[55:48]!=8'h00 && cwo_reg_full[ODD]==1'b0 && grant_cw[0]==1'b1)
				begin
					state_cw_odd<=2'b11;
					cwo_reg_full[ODD]<=1'b1;
					cwi_reg_full[ODD]<=1'b0;
					cwdo_odd <= {cw_reg_odd_Q[63:56],cw_reg_odd_Q[55:48]-1,cw_reg_odd_Q[47:0]};
				end
			end
			2'b10: begin
				if(cwsi==1'b1 && cwri==1'b1 && polarity==1'b0) begin
					state_cw_odd<=2'b01;
					cwi_reg_full[ODD]<=1'b1;
				end
				else
					state_cw_odd<=2'b00;
			end
			2'b11: begin
				if(cwsi==1'b1 && cwri==1'b1 && polarity==1'b0) begin
					state_cw_odd<=2'b01;
					cwi_reg_full[ODD]<=1'b1;
				end
				else
					state_cw_odd<=2'b00;
			end
		endcase
	end


	if(reset)
		state_cw_even<=2'b00; // enter idle state
	else begin
		case(state_cw_even)
			2'b00: begin
				if(cwsi==1'b1 && cwri==1'b1 && polarity==1'b1) begin
					state_cw_even<=2'b01;
					cwi_reg_full[EVEN]<=1'b1;
				end
			end
			2'b01: begin
				if(cw_reg_even_Q[55:48]==8'h00 && peo_reg_full[EVEN]==1'b0 && grant_pe[0]==1'b1) 
				begin
					state_cw_even<=2'b10;
					peo_reg_full[EVEN]<=1'b1;
					cwi_reg_full[EVEN]<=1'b0;
					pedo_even <= cw_reg_even_Q;
				end
				else if(cw_reg_even_Q[55:48]!=8'h00 && cwo_reg_full[EVEN]==1'b0 && grant_cw[0]==1'b1)
				begin
					state_cw_even<=2'b11;
					cwo_reg_full[EVEN]<=1'b1;
					cwi_reg_full[EVEN]<=1'b0;
					cwdo_even <= {cw_reg_even_Q[63:56],cw_reg_even_Q[55:48]-1,cw_reg_even_Q[47:0]};
				end
			end
			2'b10: begin
				if(cwsi==1'b1 && cwri==1'b1 && polarity==1'b1) begin
					state_cw_even<=2'b01;
					cwi_reg_full[EVEN]<=1'b1;
				end
				else
					state_cw_even<=2'b00;
			end
			2'b11: begin
				if(cwsi==1'b1 && cwri==1'b1 && polarity==1'b1) begin
					state_cw_even<=2'b01;
					cwi_reg_full[EVEN]<=1'b1;
				end
				else
					state_cw_even<=2'b00;
			end
		endcase
	end


//////////////////////////////////////////
//////////////////////////////////////////

	if(reset)
		state_ccw_odd<=2'b00; // enter idle state
	else begin
		case(state_ccw_odd)
			2'b00: begin
				if(ccwsi==1'b1 && ccwri==1'b1 && polarity==1'b0) begin
					state_ccw_odd<=2'b01;
					ccwi_reg_full[ODD]<=1'b1;
				end
			end
			2'b01: begin
				if(ccw_reg_odd_Q[55:48]==8'h00 && peo_reg_full[ODD]==1'b0 && grant_pe[1]==1'b1) 
				begin
					state_ccw_odd<=2'b10;
					peo_reg_full[ODD]<=1'b1;
					ccwi_reg_full[ODD]<=1'b0;
					pedo_odd <= ccw_reg_odd_Q;
				end
				else if(ccw_reg_odd_Q[55:48]!=8'h00 && ccwo_reg_full[ODD]==1'b0 && grant_ccw[0]==1'b1)
				begin
					state_ccw_odd<=2'b11;
					ccwo_reg_full[ODD]<=1'b1;
					ccwi_reg_full[ODD]<=1'b0;
					ccwdo_odd <= {ccw_reg_odd_Q[63:56],ccw_reg_odd_Q[55:48]-1,ccw_reg_odd_Q[47:0]};
				end
			end
			2'b10: begin
				if(ccwsi==1'b1 && ccwri==1'b1 && polarity==1'b0) begin
					state_ccw_odd<=2'b01;
					ccwi_reg_full[ODD]<=1'b1;
				end
				else
					state_ccw_odd<=2'b00;
			end
			2'b11: begin
				if(ccwsi==1'b1 && ccwri==1'b1 && polarity==1'b0) begin
					state_ccw_odd<=2'b01;
					ccwi_reg_full[ODD]<=1'b1;
				end
				else
					state_ccw_odd<=2'b00;
			end
		endcase
	end


	if(reset)
		state_ccw_even<=2'b00; // enter idle state
	else begin
		case(state_ccw_even)
			2'b00: begin
				if(ccwsi==1'b1 && ccwri==1'b1 && polarity==1'b1) begin
					state_ccw_even<=2'b01;
					ccwi_reg_full[EVEN]<=1'b1;
				end
			end
			2'b01: begin
				if(ccw_reg_even_Q[55:48]==8'h00 && peo_reg_full[EVEN]==1'b0 && grant_pe[1]==1'b1) 
				begin
					state_ccw_even<=2'b10;
					peo_reg_full[EVEN]<=1'b1;
					ccwi_reg_full[EVEN]<=1'b0;
					pedo_even <= ccw_reg_even_Q;
				end
				else if(ccw_reg_even_Q[55:48]!=8'h00 && ccwo_reg_full[EVEN]==1'b0 && grant_ccw[0]==1'b1)
				begin
					state_ccw_even<=2'b11;
					ccwo_reg_full[EVEN]<=1'b1;
					ccwi_reg_full[EVEN]<=1'b0;
					ccwdo_even <= {ccw_reg_even_Q[63:56],ccw_reg_even_Q[55:48]-1,ccw_reg_even_Q[47:0]};
				end
			end
			2'b10: begin
				if(ccwsi==1'b1 && ccwri==1'b1 && polarity==1'b1) begin
					state_ccw_even<=2'b01;
					ccwi_reg_full[EVEN]<=1'b1;
				end
				else
					state_ccw_even<=2'b00;
			end
			2'b11: begin
				if(ccwsi==1'b1 && ccwri==1'b1 && polarity==1'b1) begin
					state_ccw_even<=2'b01;
					ccwi_reg_full[EVEN]<=1'b1;
				end
				else
					state_ccw_even<=2'b00;
			end
		endcase
	end

//////////////////////////
///////////////////////////
///////////////////////////////////////

	if(reset)
		state_pe_odd<=2'b00;
	else begin
		case(state_pe_odd)
			2'b00: begin
				if(pesi==1'b1 && peri==1'b1 && polarity==1'b0) begin
					state_pe_odd<=2'b01;
					pei_reg_full[ODD]<=1'b1;
				end
			end
			2'b01: begin
				if(pe_reg_odd_Q[62]==1'b0 && cwo_reg_full[ODD]==1'b0 && grant_cw[1]) begin
					state_pe_odd<=2'b10;
					cwo_reg_full[ODD]<=1'b1;
					pei_reg_full[ODD]<=1'b0;
					cwdo_odd<={pe_reg_odd_Q[63:56],pe_reg_odd_Q[55:48]-1,pe_reg_odd_Q[47:0]};
				end
				else if(pe_reg_odd_Q[62]==1'b1 && cwo_reg_full[ODD]==1'b0 && grant_ccw[1]) begin
					state_pe_odd<=2'b10;
					ccwo_reg_full[ODD]<=1'b1;
					pei_reg_full[ODD]<=1'b0;
					ccwdo_odd<={pe_reg_odd_Q[63:56],pe_reg_odd_Q[55:48]-1,pe_reg_odd_Q[47:0]};
				end
			end
			2'b10: begin
				if(pesi==1'b1 && peri==1'b1 && polarity==1'b0) begin
					state_pe_odd<=2'b01;
					pei_reg_full[ODD]<=1'b1;
				end
				else
					state_pe_odd<=2'b00;
			end
			2'b11: begin
				if(pesi==1'b1 && peri==1'b1 && polarity==1'b0) begin
					state_pe_odd<=2'b01;
					pei_reg_full[ODD]<=1'b1;
				end
				else
					state_pe_odd<=2'b00;
			end
		endcase
	end

	if(reset)
		state_pe_even<=2'b00;
	else begin
		case(state_pe_even)
			2'b00: begin
				if(pesi==1'b1 && peri==1'b1 && polarity==1'b1) begin
					state_pe_even<=2'b01;
					pei_reg_full[EVEN]<=1'b1;
				end
			end
			2'b01: begin
				if(pe_reg_even_Q[62]==1'b0 && cwo_reg_full[EVEN]==1'b0 && grant_cw[1]) begin
					state_pe_even<=2'b10;
					cwo_reg_full[EVEN]<=1'b1;
					pei_reg_full[EVEN]<=1'b0;
					cwdo_even<={pe_reg_even_Q[63:56],pe_reg_even_Q[55:48]-1,pe_reg_even_Q[47:0]};
				end
				else if(pe_reg_even_Q[62]==1'b1 && cwo_reg_full[EVEN]==1'b0 && grant_ccw[1]) begin
					state_pe_even<=2'b10;
					ccwo_reg_full[EVEN]<=1'b1;
					pei_reg_full[EVEN]<=1'b0;
					ccwdo_even<={pe_reg_even_Q[63:56],pe_reg_even_Q[55:48]-1,pe_reg_even_Q[47:0]};
				end
			end
			2'b10: begin
				if(pesi==1'b1 && peri==1'b1 && polarity==1'b1) begin
					state_pe_even<=2'b01;
					pei_reg_full[EVEN]<=1'b1;
				end
				else
					state_pe_even<=2'b00;
			end
			2'b11: begin
				if(pesi==1'b1 && peri==1'b1 && polarity==1'b1) begin
					state_pe_even<=2'b01;
					pei_reg_full[EVEN]<=1'b1;
				end
				else
					state_pe_even<=2'b00;
			end
		endcase
	end
end
endmodule
