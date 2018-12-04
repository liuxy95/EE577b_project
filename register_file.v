module register_file(clk,reset,wen,rA,rB,rD,doutA,doutB,din,ppp);
input clk,reset,wen;
input[0:63]	din;
input[0:4]	rA,rB,rD; 
input[0:2]	ppp;
output reg [0:63] doutA,doutB;

reg[0:63] RF [0:31];
integer k,i;

/*assign doutA = (rA == 0)? 0:RF[rA];
assign doutA = (rD==rA && rA !=0) ? din : RF[rA]; //with internal forwarding
assign doutB = (rD==rB && rA !=0) ? din : RF[rB];
*/
always @(*)
begin
	if (rD==rA && rA !=0) 
	begin
		if(ppp == 3'b000)
			doutA = din;
		else if (ppp == 3'b001)
			doutA = {din[0:31],RF[rA][32:63]};
		else if (ppp == 3'b010)
			doutA = {RF[rA][0:31],din[32:63]};
		else if (ppp == 3'b011)
			begin
				doutA[0:15] = {din[0:7],RF[rA][8:15]};
				doutA[0+16:15+16] = {din[0+16:7+16],RF[rA][8+16:15+16]};
				doutA[0+32:15+32] = {din[0+32:7+32],RF[rA][8+32:15+32]};
				doutA[0+48:15+48] = {din[0+48:7+48],RF[rA][8+48:15+48]};
			end
		else begin
				doutA[0:15] = {RF[rA][0:7],din[8:15]};
				doutA[0+16:15+16] = {RF[rA][0+16:7+16],din[8+16:15+16]};
				doutA[0+32:15+32] = {RF[rA][0+32:7+32],din[8+32:15+32]};
				doutA[0+48:15+48] = {RF[rA][0+48:7+48],din[8+48:15+48]};
		end
			
	end
	
	else if (rA ==0)
		doutA =0;
	else 
		doutA = RF[rA]; 
end

always @(*)
begin
	if (rD==rB && rB !=0) 
	begin
		if(ppp == 3'b000)
			doutB = din;
		else if (ppp == 3'b001)
			doutB = {din[0:31],RF[rB][32:63]};
		else if (ppp == 3'b010)
			doutB = {RF[rB][0:31],din[32:63]};
		else if (ppp == 3'b011)
			begin
				doutB[0:15] = {din[0:7],RF[rB][8:15]};
				doutB[0+16:15+16] = {din[0+16:7+16],RF[rB][8+16:15+16]};
				doutB[0+32:15+32] = {din[0+32:7+32],RF[rB][8+32:15+32]};
				doutB[0+48:15+48] = {din[0+48:7+48],RF[rB][8+48:15+48]};
			end
		else begin
				doutB[0:15] = {RF[rB][0:7],din[8:15]};
				doutB[0+16:15+16] = {RF[rB][0+16:7+16],din[8+16:15+16]};
				doutB[0+32:15+32] = {RF[rB][0+32:7+32],din[8+32:15+32]};
				doutB[0+48:15+48] = {RF[rB][0+48:7+48],din[8+48:15+48]};
		end
			
	end
	
	else if (rB ==0)
		doutB =0;
	else 
		doutB = RF[rB]; 
end

always @(posedge clk) 
begin
	if(reset) begin
		for(k=0;k<32;k=k+1)
			RF[k]<=64'h0000_0000_0000_0000;
	end
	else begin
		if(wen && rD!=5'b00000) begin
			if(ppp==3'b000)
				RF[rD]<=din;
			else if(ppp==3'b001)
				RF[rD][0:31]<=din[0:31];
			else if(ppp==3'b010)
				RF[rD][32:63]<=din[32:63];
			else if(ppp==3'b011) begin
				RF[rD][48:55]<=din[48:55];
				RF[rD][32:39]<=din[32:39];
				RF[rD][16:23]<=din[16:23];
				RF[rD][0:7]<=din[0:7];
			end
			else if(ppp==3'b100) begin
				RF[rD][56:63]<=din[56:63];
				RF[rD][40:47]<=din[40:47];
				RF[rD][24:31]<=din[24:31];
				RF[rD][8:15]<=din[8:15];
			end			
		end	
	end
end
endmodule