`timescale 1ns/10ps
module tb;
//parameter	clk_period=4;

reg CLK,RST,pesi0,pesi1,pesi2,pesi3;
reg[63:0] pedi0,pedi1,pedi2,pedi3;
reg pero0,pero1,pero2,pero3;
wire peso0,peso1,peso2,peso3;
wire[63:0] pedo0,pedo1,pedo2,pedo3;
wire peri0,peri1,peri2,peri3;
wire polarity0,polarity1,polarity2,polarity3;
integer f;

router_ring_4   router_ring(CLK,RST,polarity0,polarity1,polarity2,polarity3,pesi0,peri0,pedi0,pesi1,peri1,
							pedi1,pesi2,peri2,pedi2,pesi3,peri3,pedi3,
							peso0,pero0,pedo0,peso1,pero1,pedo1,peso2,pero2,pedo2,peso3,pero3,pedo3);

always
	#2 CLK=~CLK;
							
initial
begin
	//f=$fopen("router_ring.out","w");
	//$fmonitor(f,"pedi_0=%64b\npedi_1=%64b\npedi_2=%64b\npedi_3=%64b\n-----------\n",pedi0,pedi1,pedi2,pedi3);
	// innitial state
	CLK=1'b1;
	RST=1'b1; //reset for 5 clock
	pedi0=64'h0000_0000_0000_0000;
	pedi1=64'h0000_0000_0000_0000;
	pedi2=64'h0000_0000_0000_0000;
	pedi3=64'h0000_0000_0000_0000;
	pesi0=1'b0; //send ready signals from processors are set to inactive
	pesi1=1'b0;
	pesi2=1'b0;
	pesi3=1'b0;
	pero0=1'b1; //receive ready signals from processors are set to active, and keep active during simulation
	pero1=1'b1;
	pero2=1'b1;
	pero3=1'b1;
	#20;
	RST=1'b0;
	pedi0={polarity0,1'b1,6'b000000,8'h01,16'h0000,32'h1234_5678};
	pesi0=1'b1;
	#4;
	pedi0={polarity0,1'b0,6'b000000,8'h02,16'h0000,32'h1234_5678};
	#20;
	//$fclose(f);
	//$finish;
end
endmodule