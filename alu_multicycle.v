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
				if(ww == 2'b00) begin 
						dout[0:7] = oprA[0:7] + oprB[0:7];
						dout[8:15] = oprA[8:15] + oprB[8:15];
						dout[8+8:15+8] = oprA[8+8:15+8] + oprB[8+8:15+8];
						dout[8+16:15+16] = oprA[8+16:15+16] + oprB[8+16:15+16];
						dout[8+24:15+24] = oprA[8+24:15+24] + oprB[8+24:15+24];
						dout[8+32:15+32] = oprA[8+32:15+32] + oprB[8+32:15+32];
						dout[8+40:15+40] = oprA[8+40:15+40] + oprB[8+40:15+40];
						dout[8+48:15+48] = oprA[8+48:15+48] + oprB[8+48:15+48];
				end
				else if(ww == 2'b01) begin 
						dout[0:15] = oprA[0:15] + oprB[0:15];
						dout[16:31] = oprA[16:31] + oprB[16:31];
						dout[16+16:31+16] = oprA[16+16:31+16] + oprB[16+16:31+16];
						dout[16+32:31+32] = oprA[16+32:31+32] + oprB[16+32:31+32];
				end
				else if (ww == 2'b10)begin 
						dout[0:31] = oprA[0:31] + oprB[0:31];
						dout[0+32:31+32] = oprA[0+32:31+32] + oprB[0+32:31+32];
				end
				else 
					dout[0:63] = oprA[0:63] + oprB[0:63];
		
			end
			6'b000110: begin // sub
						if(ww == 2'b00) begin 
						dout[0:7] = oprA[0:7] + ~oprB[0:7]+1;
						dout[8:15] = oprA[8:15] + ~oprB[8:15]+1;
						dout[8+8:15+8] = oprA[8+8:15+8] + ~oprB[8+8:15+8]+1;
						dout[8+16:15+16] = oprA[8+16:15+16] + ~oprB[8+16:15+16]+1;
						dout[8+24:15+24] = oprA[8+24:15+24] + ~oprB[8+24:15+24]+1;
						dout[8+32:15+32] = oprA[8+32:15+32] + ~oprB[8+32:15+32]+1;
						dout[8+40:15+40] = oprA[8+40:15+40] + ~oprB[8+40:15+40]+1;
						dout[8+48:15+48] = oprA[8+48:15+48] + ~oprB[8+48:15+48]+1;
				end
				else if(ww == 2'b01) begin 
						dout[0:15] = oprA[0:15] + ~oprB[0:15]+1;
						dout[16:31] = oprA[16:31] + ~oprB[16:31]+1;
						dout[16+16:31+16] = oprA[16+16:31+16] + ~oprB[16+16:31+16]+1;
						dout[16+32:31+32] = oprA[16+32:31+32] + ~oprB[16+32:31+32]+1;
				end
				else if (ww == 2'b10)begin 
						dout[0:31] = oprA[0:31] + ~oprB[0:31]+1;
						dout[0+32:31+32] = oprA[0+32:31+32] + ~oprB[0+32:31+32]+1;
				end
				else 
					dout[0:63] = oprA[0:63] + ~oprB[0:63]+1;
				
				
			end
			6'b000111: begin // mul even
				if(ww == 2'b00) begin 
						dout[0:15] = oprA[0:7] * oprB[0:7];
						dout[16:31] = oprA[16:23] * oprB[16:23];
						dout[32:47] = oprA[32:39] * oprB[32:39];
						dout[48:63] = oprA[48:55] * oprB[48:55];

				end
				else if(ww == 2'b01) begin 
						dout[0:31] = oprA[0:15] * oprB[0:15];
						dout[32:63] = oprA[32:47] * oprB[32:47];
				end
				else begin 
						dout[0:63] = oprA[0:31] * oprB[0:31];
				end
			end
			6'b001000: begin // mul odd
				if(ww == 2'b00) begin 
						dout[0:15] = oprA[8:15] * oprB[8:15];
						dout[16:31] = oprA[24:31] * oprB[24:31];
						dout[32:47] = oprA[40:47] * oprB[40:47];
						dout[48:63] = oprA[56:63] * oprB[56:63];
				end
				else if(ww == 2'b01) begin 
						dout[0:31] = oprA[16:31] * oprB[16:31];
						dout[32:63] = oprA[48:63] * oprB[48:63];
				end
				else begin 
						dout[0:63] = oprA[32:63] * oprB[32:63];
				end
			end
			default: 
				dout = 64'h0000_0000_0000_0000;
		endcase
	end
end
endmodule
