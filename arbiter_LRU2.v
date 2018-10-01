module arbiter_LRU2 (grant_vector, req_vector, CLK, RST);
output [1:0] grant_vector;
input [1:0] req_vector;
input CLK, RST;
//your code here
reg[1:0] grant_vector;
reg flag;

always @(posedge CLK)
begin
	if(RST) begin
		grant_vector<=2'b00;
		flag<=1'b0;
	end
	else begin
		if(req_vector==2'b00)
			grant_vector<=2'b00;
		else if(req_vector==2'b10)
			grant_vector<=2'b10;
		else if(req_vector==2'b01)
			grant_vector<=2'b01;
		else if(req_vector==2'b11) begin
			if(flag)
				grant_vector<=2'b01;
			else
				grant_vector<=2'b01;
			flag <= ~flag;
		end
	end		
end
endmodule