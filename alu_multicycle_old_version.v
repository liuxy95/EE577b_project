module alu_multicycle(aluEN,aluType,oprA,oprB,ww,imm,dout);
input aluEN;
input[0:5] aluType;
input[0:4] imm;
input[0:63] oprA,oprB;
//input[0:2] ppp;
input[0:1] ww;
output[0:63] dout;
reg[0:63] dout;
integer i;

always @(aluEN or aluType or oprA or oprB or ww or imm) begin
	if(aluEN) begin
		case(aluType)
			6'b000101: begin // add
				dout = oprA + oprB;
			end
			6'b000110: begin // sub
				dout = oprA + ~oprB + 1;
			end
			6'b001000: begin // mul even
				if(ww == 2'b00) begin 
					for (i=0; i<63; i= i+16)
						{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
						dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15]} 
						= {oprA[i+8],oprA[i+9],oprA[i+10],oprA[i+11],oprA[i+12],oprA[i+13],oprA[i+14],oprA[i+15]} * 
						{oprB[i+8],oprB[i+9],oprB[i+10],oprB[i+11],oprB[i+12],oprB[i+13],oprB[i+14],oprB[i+15]};
				end
				else if(ww == 2'b01) begin 
					for (i=0; i<63; i= i+32)
						{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
						dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15],dout[i+16],
						dout[i+17],dout[i+18],dout[i+19],dout[i+20],dout[i+21],dout[i+22],dout[i+23],dout[i+24],
						dout[i+25],dout[i+26],dout[i+27],dout[i+28],dout[i+29],dout[i+30],dout[i+31]}
						= {oprA[i+16],oprA[i+17],oprA[i+18],oprA[i+19],oprA[i+20],oprA[i+21],oprA[i+22],oprA[i+23],oprA[i+24],
						oprA[i+25],oprA[i+26],oprA[i+27],oprA[i+28],oprA[i+29],oprA[i+30],oprA[i+31]}
						*{oprB[i+16],oprB[i+17],oprB[i+18],oprB[i+19],oprB[i+20],oprB[i+21],oprB[i+22],oprB[i+23],oprB[i+24],
						oprB[i+25],oprB[i+26],oprB[i+27],oprB[i+28],oprB[i+29],oprB[i+30],oprB[i+31]};
				end
				else begin 
						dout = oprA[32:63] * oprB[32:63];
				end
			end
			6'b000111: begin // mul odd
				if(ww == 2'b00) begin 
					for (i=0; i<63; i= i+16)
						{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
						dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15]} = 
						{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7]} *
						{oprB[i],oprB[i+1],oprB[i+2],oprB[i+3],oprB[i+4],oprB[i+5],oprB[i+6],oprB[i+7]};
				end
				else if(ww == 2'b01) begin 
					for (i=0; i<63; i= i+32)
						{dout[i],dout[i+1],dout[i+2],dout[i+3],dout[i+4],dout[i+5],dout[i+6],dout[i+7],dout[i+8],
						dout[i+9],dout[i+10],dout[i+11],dout[i+12],dout[i+13],dout[i+14],dout[i+15],dout[i+16],
						dout[i+17],dout[i+18],dout[i+19],dout[i+20],dout[i+21],dout[i+22],dout[i+23],dout[i+24],
						dout[i+25],dout[i+26],dout[i+27],dout[i+28],dout[i+29],dout[i+30],dout[i+31]} = 
						{oprA[i],oprA[i+1],oprA[i+2],oprA[i+3],oprA[i+4],oprA[i+5],oprA[i+6],oprA[i+7],oprA[i+8],
							oprA[i+9],oprA[i+10],oprA[i+11],oprA[i+12],oprA[i+13],oprA[i+14],oprA[i+15]}
							* {oprB[i],oprB[i+1],oprB[i+2],oprB[i+3],oprB[i+4],oprB[i+5],oprB[i+6],oprB[i+7],oprB[i+8],
							oprB[i+9],oprB[i+10],oprB[i+11],oprB[i+12],oprB[i+13],oprB[i+14],oprB[i+15]};
				end
				else begin 
						dout = oprA[0:31] * oprB[0:31];
				end
			end
			default: 
				dout = 64'h0000_0000_0000_0000;
		endcase
	end
end
endmodule
