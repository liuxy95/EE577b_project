module alu(aluEN,aluType,oprA,oprB,ww,imm,dout);
input aluEN;
input[0:5] aluType;
input[0:4] imm;
input[0:63] oprA,oprB;
//input[0:2] ppp;
input[0:1] ww;
output[0:63] dout;
//reg[0:63] dout;

wire multicycle;
wire[0:63] doutMult,doutSingle;

assign multicycle = ((aluType==6'b000101 || aluType==6'b000110) && (ww==2'b11)) || aluType==6'b000111 || aluType==6'b001000;

alu_multicycle aluMult(aluEN,aluType,oprA,oprB,ww,imm,doutMult);
alu_singlecycle aluSingle(aluEN,aluType,oprA,oprB,ww,imm,doutSingle);

assign dout = multicycle ? doutMult : doutSingle;

endmodule













