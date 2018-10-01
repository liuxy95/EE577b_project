module reg_64bit(clk,reset,enable,data_in,Q);
input clk,reset,enable;
input[63:0] data_in;
output[63:0] Q;
reg[63:0] Q;

always @(posedge clk)
begin
	if(reset)
		Q<={64{1'b0}};
	else begin
		if(enable)
			Q<=data_in;
	end
end
endmodule