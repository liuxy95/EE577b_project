module alu_singlecycle(aluEN,aluType,oprA,oprB,ww,imm,dout);
input aluEN;
input[0:5] aluType;
input[0:4] imm;
input[0:63] oprA,oprB;
//input[0:2] ppp;
input[0:1] ww;
output[0:63] dout;
reg[0:63] dout;
integer temp1,i;
always @(aluEN or aluType or oprA or oprB or ww or imm) 
begin
	if(aluEN) begin
		case(aluType)
		6'b000000:  // and
			dout = oprA & oprB;
		6'b000001: // or
			dout = oprA | oprB;
		6'b000010:  // xor
			dout = oprA ^ oprB;
		6'b000011:  // not
			dout = ~oprA;
		6'b000100: // move
			dout = oprA;
		6'b000101: begin // add
			if(ww==2'b00) begin
				for(i=0;i<63;i=i+8)
						{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7]} = 
						{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7]}+
						{oprB[i],oprB[i+1],oprB[i+2],oprB[i+3],oprB[i+4],oprB[i+5],oprB[i+6],oprB[i+7]};
			end
			else if(ww==2'b01) begin
				for(i=0;i<63;i=i+16)
						{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
						dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15]} = 
						{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7],
						oprA[i+8],oprA[i+9],oprA[i+10],oprA[i+11],oprA[i+12],oprA[i+13],oprA[i+14],oprA[i+15]}
						+{oprB[i],oprB[i+1],oprB[i+2],oprB[i+3],oprB[i+4],oprB[i+5],oprB[i+6],oprB[i+7],oprB[i+8],
						oprB[i+9],oprB[i+10],oprB[i+11],oprB[i+12],oprB[i+13],oprB[i+14],oprB[i+15]};
			end
			else begin
				for(i=0;i<63;i=i+32)
					{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
					dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15],dout[i+16],
					dout[i+17],dout[i+18],dout[i+19],dout[i+20],dout[i+21],dout[i+22],dout[i+23],dout[i+24],
					dout[i+25],dout[i+26],dout[i+27],dout[i+28],dout[i+29],dout[i+30],dout[i+31]} = 
						{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7],
						oprA[i+8],oprA[i+9],oprA[i+10],oprA[i+11],oprA[i+12],oprA[i+13],oprA[i+14],oprA[i+15],
						oprA[i+16],oprA[i+17],oprA[i+18],oprA[i+19],oprA[i+20],oprA[i+21],oprA[i+22],oprA[i+23],
						oprA[i+24],oprA[i+25],oprA[i+26],oprA[i+27],oprA[i+28],oprA[i+29],oprA[i+30],oprA[i+31]}
						+{oprB[i],oprB[i+1],oprB[i+2],oprB[i+3],oprB[i+4],oprB[i+5],oprB[i+6],oprB[i+7],oprB[i+8],
						oprB[i+9],oprB[i+10],oprB[i+11],oprB[i+12],oprB[i+13],oprB[i+14],oprB[i+15],oprB[i+16],
						oprB[i+17],oprB[i+18],oprB[i+19],oprB[i+20],oprB[i+21],oprB[i+22],oprB[i+23],oprB[i+24],
						oprB[i+25],oprB[i+26],oprB[i+27],oprB[i+28],oprB[i+29],oprB[i+30],oprB[i+31]};
			end
		end
		6'b000110: begin // sub
			if(ww==2'b00) begin
				for(i=0;i<63;i=i+8)
						{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7]} = 
						{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7]}+
						~{oprB[i],oprB[i+1],oprB[i+2],oprB[i+3],oprB[i+4],oprB[i+5],oprB[i+6],oprB[i+7]}+1;

			end
			else if(ww==2'b01) begin
				for(i=0;i<63;i=i+16)
					{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
					dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15]} = 
						{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7],oprA[i+8],
						oprA[i+9],oprA[i+10],oprA[i+11],oprA[i+12],oprA[i+13],oprA[i+14],oprA[i+15]}
						+~{oprB[i],oprB[i+1],oprB[i+2],oprB[i+3],oprB[i+4],oprB[i+5],oprB[i+6],oprB[i+7],oprB[i+8],
						oprB[i+9],oprB[i+10],oprB[i+11],oprB[i+12],oprB[i+13],oprB[i+14],oprB[i+15]}+1;
			end
			else begin
				for(i=0;i<63;i=i+32)
					{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
					dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15],dout[i+16],
					dout[i+17],dout[i+18],dout[i+19],dout[i+20],dout[i+21],dout[i+22],dout[i+23],dout[i+24],
					dout[i+25],dout[i+26],dout[i+27],dout[i+28],dout[i+29],dout[i+30],dout[i+31]} = 
						{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7],oprA[i+8],
						oprA[i+9],oprA[i+10],oprA[i+11],oprA[i+12],oprA[i+13],oprA[i+14],oprA[i+15],
						oprA[i+16],oprA[i+17],oprA[i+18],oprA[i+19],oprA[i+20],oprA[i+21],oprA[i+22],
						oprA[i+23],oprA[i+24],oprA[i+25],oprA[i+26],oprA[i+27],oprA[i+28],oprA[i+29],oprA[i+30],oprA[i+31]}
						+~{oprB[i],oprB[i+1],oprB[i+2],oprB[i+3],oprB[i+4],oprB[i+5],oprB[i+6],oprB[i+7],oprB[i+8],
						oprB[i+9],oprB[i+10],oprB[i+11],oprB[i+12],oprB[i+13],oprB[i+14],oprB[i+15],
						oprB[i+16],oprB[i+17],oprB[i+18],oprB[i+19],oprB[i+20],oprB[i+21],oprB[i+22],oprB[i+23],oprB[i+24],
						oprB[i+25],oprB[i+26],oprB[i+27],oprB[i+28],oprB[i+29],oprB[i+30],oprB[i+31]}+1;
			end
		end
		6'b001001: begin // rotate by half
			if(ww==2'b00) begin
				for(i=0;i<=64-8;i=i+8)
					{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7]}
					= {{oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7]},{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3]}};
			end
			else if(ww==2'b01) begin
				for(i=0;i<=64-16;i=i+16)
					{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
					dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15]}
					= {{oprA[i+8],oprA[i+9],oprA[i+10],oprA[i+11],oprA[i+12],oprA[i+13],oprA[i+14],oprA[i+15]},
					{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7]}};
			end
			else if(ww==2'b10) begin
				for(i=0;i<=64-32;i=i+32)
					{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
					dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15],dout[i+16],
					dout[i+17],dout[i+18],dout[i+19],dout[i+20],dout[i+21],dout[i+22],dout[i+23],dout[i+24],
					dout[i+25],dout[i+26],dout[i+27],dout[i+28],dout[i+29],dout[i+30],dout[i+31]} = 
					{{oprA[i+16],oprA[i+17],oprA[i+18],oprA[i+19],oprA[i+20],oprA[i+21],oprA[i+22],oprA[i+23],oprA[i+24],
					oprA[i+25],oprA[i+26],oprA[i+27],oprA[i+28],oprA[i+29],oprA[i+30],oprA[i+31]},
					{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7],oprA[i+8],
						oprA[i+9],oprA[i+10],oprA[i+11],oprA[i+12],oprA[i+13],oprA[i+14],oprA[i+15]}};
			end
			else begin
					dout = {oprA[32:63],oprA[0:31]};
			end
		end
		6'b001010: begin  // logical shift left
			if(ww == 2'b00) begin 
					temp1 = oprB[8-3:7];
					dout[0:7] = oprA[0:7] <<temp1;
					temp1 = oprB[5+8:7+8];
					dout[8:15] = oprA[8:8+7]<<temp1;
					temp1 = oprB[5+16:7+16];
					dout[16:23] = oprA[16:16+7]<<temp1;
					temp1 = oprB[5+24:7+24];
					dout[24:31] = oprA[24:24+7]<<temp1;
					temp1 = oprB[5+32:7+32];
					dout[32:39] = oprA[32:32+7]<<temp1;
					temp1 = oprB[5+40:7+40];
					dout[40:47] = oprA[40:40+7]<<temp1;
					temp1 = oprB[5+48:7+48];
					dout[48:55] = oprA[48:48+7]<<temp1;
					temp1 = oprB[5+56:7+56];
					dout[56:63] = oprA[56:56+7]<<temp1;
					end
			else if(ww == 2'b01) begin 
					temp1 = oprB[16-4:15];
					dout[0:15] = oprA[0:15]<<temp1;
					temp1 = oprB[12+16:15+16];
					dout[16:31] = oprA[16:31]<<temp1;
					temp1 = oprB[32+12:15+32];   //a bug
					dout[32:47] = oprA[32:47]<<temp1;
					temp1 = oprB[60:63];  //a bug
					dout[48:63] = oprA[48:63]<<temp1;
					end
			else if(ww == 2'b10) begin 
					temp1 = oprB[27:31];
					dout[0:31] = oprA[0:31]<<temp1;
					temp1 = oprB[27+32:31+32];
					dout[32:63] = oprA[32:31+32]<<temp1;
					end
			else begin 
					temp1 = oprB[58:63];
					dout[0:64-1] = oprA[0:63]<<temp1;
			end
		end
		6'b001011: begin // logical shift left imm
			if(ww == 2'b00) begin  
					temp1 = imm[2:4];
					dout[0:8-1] = oprA[0:7]<<temp1;
					dout[8:16-1]=oprA[8:8+7]<<temp1;
					dout[16:24-1] = oprA[16:16+7]<<temp1;
					dout[24:32-1] = oprA[24:24+7]<<temp1;
					dout[32:40-1] = oprA[32:32+7]<<temp1;
					dout[40:48-1] = oprA[40:40+7]<<temp1;
					dout[48:56-1] = oprA[48:48+7]<<temp1;
					dout[56:63] = oprA[56:56+7]<<temp1;
					end
			else if(ww == 2'b01) begin 
					temp1 = imm[1:4];
					dout[0:15] = oprA[0:15]<<temp1;
					dout[16:31] = oprA[16:16+15]<<temp1;
					dout[32:47] = oprA[32:15+32]<<temp1;
					dout[48:63] = oprA[48:48+15]<<temp1;
					end
			else if(ww == 2'b10) begin 
					temp1 = imm[0:4];
					dout[0:32-1] = oprA[0:31]<<temp1;
					dout[32:63] = oprA[32:31+32]<<temp1;
					end
			else begin 
					temp1 = imm[0:4];
					dout[0:64-1] = oprA[0:63]<<temp1;
			end
		end
		6'b001100: begin  // logical shift right
			if(ww == 2'b00) begin 
					temp1 = oprB[8-3:7];
					dout[0:7] = oprA[0:7] >>temp1;
					temp1 = oprB[5+8:7+8];
					dout[8:15] = oprA[8:8+7]>>temp1;
					temp1 = oprB[5+16:7+16];
					dout[16:23] = oprA[16:16+7]>>temp1;
					temp1 = oprB[5+24:7+24];
					dout[24:31] = oprA[24:24+7]>>temp1;
					temp1 = oprB[5+32:7+32];
					dout[32:39] = oprA[32:32+7]>>temp1;
					temp1 = oprB[5+40:7+40];
					dout[40:47] = oprA[40:40+7]>>temp1;
					temp1 = oprB[5+48:7+48];
					dout[48:55] = oprA[48:48+7]>>temp1;
					temp1 = oprB[5+56:7+56];
					dout[56:63] = oprA[56:56+7]>>temp1;
					end
			else if(ww == 2'b01) begin 
					temp1 = oprB[16-4:15];
					dout[0:15] = oprA[0:15]>>temp1;
					temp1 = oprB[12+16:15+16];
					dout[16:31] = oprA[16:31]>>temp1;
					temp1 = oprB[32+12:15+32];
					dout[32:47] = oprA[32:47]>>temp1;
					temp1 = oprB[48+12:63];
					dout[48:63] = oprA[48:63]>>temp1;
					end
			else if(ww == 2'b10) begin 
					temp1 = oprB[27:31];
					dout[0:31] = oprA[0:31]>>temp1;
					temp1 = oprB[27+32:31+32];
					dout[32:63] = oprA[32:31+32]>>temp1;
					end
			else begin 
					temp1 = oprB[58:63];
					dout[0:64-1] = oprA[0:63]>>temp1;
			end
		end
		6'b001101: begin  // logical shift right imm
			if(ww == 2'b00) begin 
					temp1 = imm[2:4];
					dout[0:8-1] = oprA[0:7]>>temp1;
					dout[8:16-1]=oprA[8:8+7]>>temp1;
					dout[16:24-1] = oprA[16:16+7]>>temp1;
					dout[24:32-1] = oprA[24:24+7]>>temp1;
					dout[32:40-1] = oprA[32:32+7]>>temp1;
					dout[40:48-1] = oprA[40:40+7]>>temp1;
					dout[48:56-1] = oprA[48:48+7]>>temp1;
					dout[56:63] = oprA[56:56+7]>>temp1;
					end
			else if(ww == 2'b01) begin 
					temp1 = imm[1:4];
					dout[0:15] = oprA[0:15]>>temp1;
					dout[16:31] = oprA[16:16+15]>>temp1;
					dout[32:47] = oprA[32:15+32]>>temp1;
					dout[48:63] = oprA[48:48+15]>>temp1;
					end
			else if(ww == 2'b10) begin 
					temp1 = imm[0:4];
					dout[0:32-1] = oprA[0:31]>>temp1;
					dout[32:63] = oprA[32:31+32]>>temp1;
					end
			else begin 
					temp1 = imm[0:4];
					dout[0:64-1] = oprA[0:63]>>temp1;
			end
		end
		6'b001110: begin  // arithmetic shift right
			if(ww == 2'b00) begin 
					temp1 = oprB[5:7];
					dout[0:7] = ($signed(oprA[0:7])) >>>temp1;
					temp1 = oprB[5+8:7+8];
					dout[8:15] = ($signed(oprA[8:8+7]))>>>temp1;
					temp1 = oprB[5+16:7+16];
					dout[16:23] = ($signed(oprA[16:16+7]))>>>temp1;
					temp1 = oprB[5+24:7+24];
					dout[24:31] = ($signed(oprA[24:24+7]))>>>temp1;
					temp1 = oprB[5+32:7+32];
					dout[32:39] = ($signed(oprA[32:32+7]))>>>temp1;
					temp1 = oprB[5+40:7+40];
					dout[40:47] = ($signed(oprA[40:40+7]))>>>temp1;
					temp1 = oprB[5+48:7+48];
					dout[48:55] = ($signed(oprA[48:48+7]))>>>temp1;
					temp1 = oprB[5+56:7+56];
					dout[56:63] = ($signed(oprA[56:56+7]))>>>temp1;
					end
			else if(ww == 2'b01) begin 
					temp1 = oprB[12:15];
					dout[0:15] = ($signed(oprA[0:15]))>>>temp1;
					temp1 = oprB[12+16:15+16];
					dout[16:31] = ($signed(oprA[16:31]))>>>temp1;
					temp1 = oprB[44:47];
					dout[32:47] = ($signed(oprA[32:47]))>>>temp1;
					temp1 = oprB[60:63];
					dout[48:63] = ($signed(oprA[48:63]))>>>temp1;
					end
			else if(ww == 2'b10) begin 
					temp1 = oprB[27:31];
					dout[0:31] = ($signed(oprA[0:31]))>>>temp1;
					temp1 = oprB[27+32:31+32];
					dout[32:63] = ($signed(oprA[32:31+32]))>>>temp1;
					end
			else begin 
					temp1 = oprB[58:63];
				  dout[0:64-1] = ($signed(oprA[0:63]))>>>temp1;
			end
		end
		6'b001111: begin  // arithmetic shift right imm
			if(ww == 2'b00) begin 
					temp1 = imm[2:4];
					dout[0:7] = ($signed(oprA[0:7])) >>> temp1;
					dout[8:15] = ($signed(oprA[8:8+7]))>>> temp1;
					dout[16:23] = ($signed(oprA[16:16+7]))>>>temp1;
					dout[24:31] = ($signed(oprA[24:24+7]))>>>temp1;
					dout[32:39] = ($signed(oprA[32:32+7]))>>>temp1;
					dout[40:47] = ($signed(oprA[40:40+7]))>>>temp1;
					dout[48:55] = ($signed(oprA[48:48+7]))>>>temp1;
					dout[56:63] = ($signed(oprA[56:56+7]))>>>temp1;
					end
			else if(ww == 2'b01) begin 
					temp1 = imm[1:4];
					dout[0:15] = ($signed(oprA[0:15]))>>>temp1;
					dout[16:31] = ($signed(oprA[16:31]))>>>temp1;
					dout[32:47] = ($signed(oprA[32:47]))>>>temp1;
					dout[48:63] = ($signed(oprA[48:63]))>>>temp1;
					end
			else if(ww == 2'b10) begin 
					temp1 = imm[0:4];
					dout[0:31] = ($signed(oprA[0:31]))>>>temp1;
					dout[32:63] = ($signed(oprA[32:31+32]))>>>temp1;
					end                   
			else begin 
					temp1 = imm[0:4];
				  dout[0:64-1] = ($signed(oprA[0:63]))>>>temp1;
			end
		end
		default:
			dout = 64'h0000_0000_0000_0000;
		endcase
	end
	else 
	dout =0;
end
endmodule













