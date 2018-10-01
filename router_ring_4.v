module router_ring_4(CLK,RST,polarity0,polarity1,polarity2,polarity3,pesi0,peri0,pedi0,pesi1,peri1,pedi1,pesi2,peri2,pedi2,pesi3,peri3,pedi3,
peso0,pero0,pedo0,peso1,pero1,pedo1,peso2,pero2,pedo2,peso3,pero3,pedo3);
input CLK,RST,pesi0,pesi1,pesi2,pesi3;
input[63:0] pedi0,pedi1,pedi2,pedi3;
input pero0,pero1,pero2,pero3;
output peso0,peso1,peso2,peso3;
output[63:0] pedo0,pedo1,pedo2,pedo3;
output peri0,peri1,peri2,peri3;
output polarity0,polarity1,polarity2,polarity3;
/*
reg polarity,peso0,peso1,peso2,peso3;
reg[63:0] pedo0,pedo1,pedo2,pedo3;
reg peri0,peri1,peri2,peri3;
*/

wire cwri_0,ccwri_0,peri_0,cwso_0,ccwso_0,peso_0;
wire[63:0] cwdo_0,ccwdo_0,pedo_0;
wire cwri_1,ccwri_1,peri_1,cwso_1,ccwso_1,peso_1;
wire[63:0] cwdo_1,ccwdo_1,pedo_1;
wire cwri_2,ccwri_2,peri_2,cwso_2,ccwso_2,peso_2;
wire[63:0] cwdo_2,ccwdo_2,pedo_2;
wire cwri_3,ccwri_3,peri_3,cwso_3,ccwso_3,peso_3;
wire[63:0] cwdo_3,ccwdo_3,pedo_3;

router router_0(CLK,RST,polarity0,cwso_3,cwri_0,cwdo_3,ccwso_1,ccwri_0,ccwdo_1,pesi0,peri0,pedi0,
				cwso_0,cwri_1,cwdo_0,ccwso_0,ccwri_3,ccwdo_0,peso0,pero0,pedo0);
				
router router_1(CLK,RST,polarity1,cwso_0,cwri_1,cwdo_0,ccwso_2,ccwri_1,ccwdo_2,pesi1,peri1,pedi1,
				cwso_1,cwri_2,cwdo_1,ccwso_1,ccwri_0,ccwdo_1,peso1,pero1,pedo1);
				
router router_2(CLK,RST,polarity2,cwso_1,cwri_2,cwdo_1,ccwso_3,ccwri_2,ccwdo_3,pesi2,peri2,pedi2,
				cwso_2,cwri_3,cwdo_2,ccwso_2,ccwri_1,ccwdo_2,peso2,pero2,pedo2);
				
router router_3(CLK,RST,polarity3,cwso_2,cwri_3,cwdo_2,ccwso_0,ccwri_3,ccwdo_0,pesi3,peri3,pedi3,
				cwso_3,cwri_0,cwdo_3,ccwso_3,ccwri_2,ccwdo_3,peso3,pero3,pedo3);

endmodule









