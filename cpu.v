//`include "./design/register_file.v"
//`include "./design/alu.v"

module cardinal_processor(clk,reset,instruction,dataIn,pc,
					  dataOut,memAddr,memEn, memWrEn);
input clk,reset;
input[0:31]	instruction;
input[0:63]	dataIn;
output [0:31] pc;
output [0:63] dataOut; //write data to data meory
output [0:31] memAddr; //write address for data memory
output memEn;  //data memory enable
output memWrEn; //data memory write enable

reg [0:31] pc;
//reg [0:63] dataOut; //write data to data meory
//reg [0:31] memAddr; //write address for data memory
//reg memEn;  //data memory enable
//reg memWrEn; //data memory write enable
/////////////////////////////////////////////////////
wire[0:31] pc_next;
////*******IF/ID pipeline register declare
reg[0:31]	IF_inst;
reg flush;
wire if_stall;
//////////// SIGNAL IN ID STAGE    //////////////////////
wire[0:31]	branch_target; //address that branch would jump to
wire[0:63] oprA,oprB; //register data output
wire aluop;	//decode result: alu operation
wire memLd;	//decode result: load, then send address to dmem in ID stage
wire memSt;
wire nicLd,nicSt; // access to NIC
wire bez,bnez; // decode result: branch instruction, BEZ & BNEZ
wire branch_taken; // branch is taken
wire id_forwarding;
wire rfw; //rf write
wire immOpr; // indicate that it is immediate operation
wire memIDAccess;
wire[0:63] branch_compare; // number used to be compared in branch operation
wire[0:4] rf_addA; // if R-type, then add is rA; if branch, then add is rD
//*******************************************************///
///////////// ID/EX PIPELINE REGISTER  ///////////////////
reg[0:63] ID_oprA,ID_oprB;
reg[0:2] ID_ppp;
reg[0:1] ID_ww;
reg[0:4] ID_rD,ID_rA,ID_rB;
reg ID_aluop,ID_memSt,ID_nicSt,ID_memLd,ID_nicLd,ID_rfw,ID_immOpr;
reg[0:5] ID_aluType;
reg[0:4] ID_imm;
reg[0:15] ID_memAddr;
////////////////////////////////////////////////
wire[0:63] alu_out;
reg [0:63] alu_oprA,alu_oprB;
wire memExAccess;
wire[0:63] data_result;
wire pipeline_stall; // when load inst in EX/MEM stage, stall IF and ID.
reg stall_flag;
wire addOrSub_64bit;
wire multOpr;
//////////////IF STAGE//////////////////////
reg[0:63] WB_data;
reg[0:4] WB_rD;
reg WB_wen;
reg[0:2] WB_ppp;

//assign memEn = memExAccess || memIDAccess;

assign pc_next = branch_taken ? branch_target:(pc+4); // mux for pc value in the next clock
													  // if branch taken, next clock pc equal to the target add, or pc+1
always @(posedge clk)
begin
	if(reset)
		pc<=32'h0000_0000;
	else begin
		if(~pipeline_stall) begin
			pc<=pc_next;	
		end
	end
end
////////////////////////////////////////////////////////
/////***********IF/ID pipeline register************/////
always @(posedge clk)
begin
	if(reset) begin
		IF_inst<=32'h0000_0000;
		flush<=1'b0;
	end
	else begin
		if(~pipeline_stall) begin
			IF_inst<=instruction;
			flush<=branch_taken;
		end
	end
end
//////////////////////////////////////////////////////////////////////////////////
////**********  ID stage  *******************/////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
////  Register File  ///// it has internal forwarding
register_file RF(clk,reset,WB_wen,rf_addA,IF_inst[16:20],WB_rD,oprA,oprB,WB_data,WB_ppp);
assign aluop = (IF_inst[0:5]==6'b101010)&&(~flush); // if flush=1, then turn this instruction to NOP
assign memLd = (IF_inst[0:5]==6'b100000)&&(~flush)&&(IF_inst[0:1]!=2'b11);
assign memSt = (IF_inst[0:5]==6'b100001)&&(~flush)&&(IF_inst[0:1]!=2'b11);
assign nicLd = (IF_inst[0:5]==6'b100000)&&(~flush)&&(IF_inst[0:1]==2'b11);
assign nicSt = (IF_inst[0:5]==6'b100001)&&(~flush)&&(IF_inst[0:1]==2'b11);
assign bez = (IF_inst[0:5]==6'b100010)&&(~flush);	
assign bnez = (IF_inst[0:5]==6'b100011)&&(~flush);
assign rfw = aluop || memLd || nicLd;
assign rf_addA = (bez||bnez||memSt||nicSt)?IF_inst[6:10]:IF_inst[11:15]; // if branch operation, then use rd to read RF data	
assign id_forwarding = (bez||bnez) && (IF_inst[6:10]==ID_rD) && ID_rfw; //if branch, and depend on previous instruction, then forwarding
assign branch_compare = id_forwarding? data_result:oprA;//////////////////////////////////
assign immOpr = ((IF_inst[26:31]==6'b001011)||(IF_inst[26:31]==6'b001101)||(IF_inst[26:31]==6'b001111)) && aluop; 
assign branch_taken = (bez && (branch_compare==64'h0000_0000_0000_0000)) || (bnez && (branch_compare!=64'h0000_0000_0000_0000));
assign branch_target = {16'h0000,IF_inst[16:31]};
//assign memAddr = {16'h0000,IF_inst[16:31]};
//assign memIDAccess = memLd || nicLd;

/////****************************************************************/////////////
/////*********** ID/EX pipeline register *******************//////////////////////
always @(posedge clk) begin
	if(reset) begin
		ID_oprA<=64'h0000_0000_0000_0000;
		ID_oprB<=64'h0000_0000_0000_0000;
		ID_ppp<=3'b000;
		ID_ww<=2'b00;
		ID_rD<=5'b00000;
		ID_aluType<=6'b000000;
		ID_aluop<=1'b0;
		ID_memSt<=1'b0;
		ID_nicSt<=1'b0;
		ID_memLd<=1'b0;
		ID_nicLd<=1'b0;
		ID_rfw<=1'b0;
		ID_imm<=5'b00000;
		ID_rA<=5'b00000;
		ID_rB<=5'b00000;
		ID_immOpr<=1'b0;
		ID_memAddr<=16'h0000;
	end
	else begin
		if(~pipeline_stall) begin
			ID_oprA<=oprA;
			ID_oprB<=oprB;
			ID_ppp<=IF_inst[21:23];
			ID_ww<=IF_inst[24:25];
			ID_rD<=(IF_inst[0:5]==6'b100001)? 0: IF_inst[6:10];
			ID_aluType<=IF_inst[26:31];
			ID_aluop<=aluop;
			ID_memSt<=memSt;
			ID_nicSt<=nicSt;
			ID_memLd<=memLd;
			ID_nicLd<=nicLd;
			ID_rfw<=rfw;
			ID_imm<=IF_inst[16:20];
			ID_immOpr<=immOpr;
			ID_rA<=rf_addA;
			ID_rB<=IF_inst[16:20];
			ID_memAddr<=IF_inst[16:31];
		end
	end
end

/////////////////////////////////////////////////////////////////
//////**********EX stage***************************//////////////

alu A(ID_aluop,ID_aluType,alu_oprA,alu_oprB,ID_ww,ID_imm,alu_out);
always @(*)
begin
if (WB_rD !=0)
begin
	if (WB_ppp == 3'b000)  
		begin
			alu_oprA = ((ID_rA==WB_rD)&&ID_aluop)?WB_data:ID_oprA;
			alu_oprB = ((ID_rB==WB_rD)&&ID_aluop&&~ID_immOpr)?WB_data:ID_oprB;
		end
	else if (WB_ppp == 3'b001 )
			begin
			alu_oprA = ((ID_rA==WB_rD)&&ID_aluop)?{WB_data[0:31],ID_oprA[32:63]} :ID_oprA;
			alu_oprB = ((ID_rB==WB_rD)&&ID_aluop&&~ID_immOpr)?{WB_data[0:31],ID_oprB[32:63]}:ID_oprB;
			end
	else if (WB_ppp == 3'b010)
			begin
			alu_oprA = ((ID_rA==WB_rD)&&ID_aluop)?{ID_oprA[0:31],WB_data[32:63]} :ID_oprA;
			alu_oprB = ((ID_rB==WB_rD)&&ID_aluop&&~ID_immOpr)?{ID_oprB[0:31],WB_data[32:63]}:ID_oprB;
			end
	else if (WB_ppp == 3'b011)
			begin
			alu_oprA = ((ID_rA==WB_rD)&&ID_aluop)?{WB_data[0:7],ID_oprA[8:15],WB_data[16:23],ID_oprA[24:31],WB_data[32:39],ID_oprA[40:47],WB_data[48:55],ID_oprA[56:63]} :ID_oprA;
			alu_oprB = ((ID_rB==WB_rD)&&ID_aluop&&~ID_immOpr)?{WB_data[0:7],ID_oprB[8:15],WB_data[16:23],ID_oprB[24:31],WB_data[32:39],ID_oprB[40:47],WB_data[48:55],ID_oprB[56:63]} :ID_oprB;
			end
	else 
		begin
			alu_oprA = ((ID_rA==WB_rD)&&ID_aluop)?{ID_oprA[0:7],WB_data[8:15],ID_oprA[16:23],WB_data[24:31],ID_oprA[32:39],WB_data[40:47],ID_oprA[48:55],WB_data[56:63]} :ID_oprA;
			alu_oprB = ((ID_rB==WB_rD)&&ID_aluop&&~ID_immOpr)?{ID_oprB[0:7],WB_data[8:15],ID_oprB[16:23],WB_data[24:31],ID_oprB[32:39],WB_data[40:47],ID_oprB[48:55],WB_data[56:63]}:ID_oprB;
		end 
end
else 
		begin
			alu_oprA = ID_oprA;
			alu_oprB = ID_oprB;
		end
		
end


assign dataOut = (ID_rA==WB_rD && WB_rD !=0)?WB_data:ID_oprA;
assign memEn = ID_memSt || ID_nicSt || ID_memLd || ID_nicLd;
assign memWrEn = ID_memSt || ID_nicSt;

assign data_result = ID_aluop?alu_out:dataIn;
assign memAddr = {16'h0000,ID_memAddr};

assign addOrSub_64bit = (ID_aluType==6'b000101 || ID_aluType==6'b000110) && (ID_ww==2'b11);
assign multOpr = (ID_aluType==6'b000111 || ID_aluType==6'b001000);
assign pipeline_stall = (ID_memLd || ID_nicLd || addOrSub_64bit || multOpr) && ~stall_flag;


always @(posedge clk) begin
	if(reset)
		stall_flag<=1'b0;
	else begin
		stall_flag<=pipeline_stall;
	end	
end

////////////////////////////////////////////////////////////////

always @(posedge clk) begin
	if(reset) begin
		WB_data<=64'h0000_0000_0000_0000;
		WB_rD<=5'b00000;
		WB_wen<=1'b0;
		WB_ppp<=3'b000;
	end
	else begin
		if(~pipeline_stall) begin
			WB_data<=data_result;
			WB_rD<=ID_rD;
			WB_wen<=ID_rfw;
			WB_ppp<=ID_ppp;
		end
	end
end
endmodule


