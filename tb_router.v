`timescale 1ns/10ps
module tb;
reg clk,reset;
reg cwsi,ccwsi,pesi,cwro,ccwro,pero;
reg[63:0] cwdi,ccwdi,pedi;
wire polarity,cwso,ccwso,peso,cwri,ccwri,peri;
wire[63:0] cwdo,ccwdo,pedo;

router	r1(clk,reset,polarity,cwsi,cwri,cwdi,ccwsi,ccwri,ccwdi,pesi,peri,pedi,cwso,cwro,cwdo,ccwso,ccwro,ccwdo,peso,pero,pedo);

always
	#2 clk=~clk;

initial
begin
	clk=1'b1;
	reset=1'b1;
	#20;
	reset=1'b0;
	#100;
end
endmodule