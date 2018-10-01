module feedback(clk,reset,a,b,c);
input clk,reset;
input[15:0] a,b;
output[15:0] c;
reg[15:0] c;
reg[15:0] a_reg,b_reg;

always @(posedge clk)
begin
	if(reset) begin
		a_reg<=16'h0000;
		b_reg<=16'h0000;
		c<=16'h0000;
	end
	else begin
		
	end
end