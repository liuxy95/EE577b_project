
module cardinal_processor(clk,reset,instruction,dataIn,pc,dataOut,memAddr,memEn, memWrEn);

input clk, reset;
input [0:31] instruction; //instruction from Instruction memory
input [0:63] dataIn; //instruction from data memory
output [0:31] pc;
output [0:63] dataOut; //write data to data meory
output [0:31] memAddr; //write address for data memory
output memEn;  //data memory enable
output memWrEn; //data memory write enable

//*************pc _signals*************
reg [0:31] pc;
reg pc_en,load_pc;
wire if_stall;
//*********if_id stage signals
wire id_stall; 
wire id_branch_happen;
reg [0:31] id_pc;
reg [0:5] id_function_bits;
reg [0:5] id_opcode;
reg [0:4] id_rs;
reg [0:4] id_rt;
reg [0:4] id_rd;
reg [0:2] id_ppp;
reg [0:1]id_ww;
reg id_flush;
reg [0:4] id_shift_amount;
reg [0:15] id_immediate_address;
//*********id stage signals*******************
reg [63:0] register [0:31];
reg [0:4] id_register_write_address;
reg id_register_write_enable; 
integer k;

reg [0:63] id_register_read_out1;
reg [0:63] id_register_read_out2;
reg [0:4] write_address;
reg [0:63] wb_register_write_data;
reg id_register_write_enable;
reg [0:2] wb_ppp;







wire [0:63] id_read_out1;
wire [0:61] id_read_out2;

wire [0:4] wb_write_address;
wire [0:63] wb_write_data;
wire wb_write_enable;
wire [0:2] wb_ppp;
 

//*****************************pc***********************
always @(posedge clk )
begin
  if(reset)
    pc <= 32'b0;
    else if(if_stall)
      pc <= pc;
   else if (load_pc ==0)
     if_pc <= pc+1;
    else if(load_pc==1)
       pc<=load_pc; 
end
//******************************if_id_stage_register*******

always @(posedge clk)
begin
  if(reset)
    begin
        id_pc <= 0;
        id_function_bits <= 0;
        id_opcode <=0;
        id_rs <=0;
        id_rt <=0;
        id_rd <=0;
        id_ppp <=0;
        id_ww <=0;
        id_flush <=0;
        id_shift_amount <=0;
        id_immediate_address <=0;
    end
     else if(id_stall)    //////////////in case of stalling; the register presever its data
       begin
        id_pc <= id_pc;
        id_function_bits <= id_function_bits;
        id_opcode <=id_opcode;
        id_rs <=id_rs;
        id_rt <=id_rt;
        id_rd <=id_rd;
        id_ppp <=id_ppp;
        id_ww <=id_ww;
        id_flush <=id_flush;  //if the branch in Id stage is dependent on the ex/mem instructions; and the wrong branch happens; the stall can keep the id_flush data and do not let the wrong flush happens
        id_shift_amount <=id_shift_amount;
        id_immediate_address <=id_immediate_address;
       end
    else 
    begin
        if(dataIn[0:5] == 6'b101010) //R-type instruction
        begin
               if((dataIn[26:31] == 6'b000011)
                 ||(dataIn[26:31] == 6'b000011)||
                 (dataIn[26:31] == 6'b000011)) //VNOT , VMOV , VRTTH
                   begin
                          id_pc <= if_pc;
                          id_function_bits <= dataIn[26:31];
                          id_opcode <=dataIn[0:5];
                          id_rs <=dataIn[11:15];
                          id_rt <=0;
                          id_rd <=dataIn[6:10];
                          id_ppp <=dataIn[21:23];
                          id_ww <=dataIn[24:25];
                          id_shift_amount <=0;
                          id_immediate_address <=0; 
                          id_flush <= id_branch_happen;     
                   end
               else if((dataIn[26:31] == 6'b000011)||(dataIn[26:31] == 6'b000011))//VSLLI , VSRLI
                  begin
                         id_pc <= if_pc;
						 id_function_bits <= dataIn[26:31];
                         id_opcode <=dataIn[0:5];
                         id_rs <=dataIn[11:15];
                         id_rt <=0;
                         id_rd <=dataIn[6:10];
                         id_ppp <=dataIn[21:23];
                         id_ww <=dataIn[24:25];
                         id_shift_amount <=dataIn[16:20];
                         id_immediate_address <=0;
                         id_flush <= id_branch_happen;
                  end
             else   //normal R-TYPE Instructions
                 begin
                         id_pc <= if_pc;
                         id_function_bits <= dataIn[26:31];
                         id_opcode <=dataIn[0:5];
                         id_rs <=dataIn[11:15];
                         id_rt <=dataIn[16:20];
                         id_rd <=dataIn[6:10];
                         id_ppp <=dataIn[21:23];
                         id_ww <=dataIn[24:25];
                         id_shift_amount <=0;
                         id_immediate_address <=0;
                         id_flush <= id_branch_happen;
                  end
            end
         else if ((dataIn[0:5] == 6'b100000)
                 ||(dataIn[0:5] == 6'b100001)
                 ||(dataIn[0:5] == 6'b100010)
                 ||(dataIn[0:5] == 6'b100011)) //VLD, VSD, VBEZ, VNEZ, VNOP
                 begin
                         id_pc <= if_pc;
                         id_function_bits <=0;
                         id_opcode <=dataIn[0:5];//use Instruction as opcode!!!!!!!!!!!!!
                         id_rs <=0;
                         id_rt <=0;
                         id_rd <=dataIn[6:10];
                         id_ppp <=0;
                         id_ww <=0;
                         id_shift_amount <=0;
                         id_immediate_address <=dataIn[16:31];
                         id_flush <= id_branch_happen;
                  end
         else   //VNOP
                 begin
                         id_pc <= if_pc;
                         id_function_bits <=0;
                         id_opcode <=dataIn[0:5];//use Instruction as opcode!!!!!!!!!!!!!
                         id_rs <=0;
                         id_rt <=0;
                         id_rd <=0;
                         id_ppp <=0;
                         id_ww <=0;
                         id_shift_amount <=0;
                         id_immediate_address <=0;
                         id_flush <= id_branch_happen;
                  end
    end
end
//********************signal here****************
reg [0:63] register [0:31];
reg [0:63] id_register_read_out1;
reg [0:63] id_register_read_out2;

//****************************************register read ******************
 always @(*)
 begin
	register[0] = 64'b0;
	id_register_read_out1 = register[id_rs];
	id_register_read_out2 = register[id_rt];
 end
 //***************************************register write******************
always @(negedge clk)
begin
  if(reset)
       begin
         for(k=0;k<32;k=k+1)
         register[k]  = 64'b0;
       end
   else if(wb_wb =1 && wb_rd !=0 && id_load_register_en ==0)//for wait two cycles;we do not need to worry about the data back and load have conflict
         begin
          if (wb_ppp==3'b000)
          register[wb_rd] <= wb_data_back;
          else if (wb_ppp==3'b001)
             register[wb_rd][0:31] <= wb_data_back[0:31];
          else if(wb_ppp==3'b010)
              register[wb_rd][32:63] <= wb_data_back[32:63];
          else if (wb_ppp==3'b011)
              begin
                for(k=0;k<64;k=k+2)
                  register[wb_rd][k] <= wb_data_back[k];
              end
          else if (wb_ppp==3'b100)
              begin
                for(k=1;k<64;k=k+2)
                  register[wb_rd][k] <= wb_data_back[k];
              end
        end   
	else if (id_load_register_en)
		register[id_rd] = dataOut;
end


//***********************ID stage; should take care of  load , sw**************
output [0:31] EA;
input [0:63] dataOut; //read data from data memory
output [0:63] dataIn; //read data from register

always @(*)
begin
	if(id_opcode == 6'b100000 &&load_wait1 ==0) //vload
		begin
			EA = {16*{0},id_immediate_address};
			if_stall_load = 1;
			id_stall_load =1;
			memEn =1;
			id_load_register_en =0;
		end
	else if (load_wait1 ==1)
		begin
			EA = 32'b0;
			if_stall_load = 0;
			id_stall_load =0;
			memEn =0;
			id_load_register_en =1;
		end
	else 
		begin
			EA = 32'b0;
			if_stall_load = 0;
			id_stall_load =0;
			memEn =0;
			id_load_register_en =0;
		end
end

always @(posedge clk) //first wait & second wait
begin
	if(reset)
		begin
		load_wait1 <=0;
		end
	else if(if_stall_load)
		begin
			load_wait1 <=if_stall_load;
		end
	else (if_stall_load ==0)
		begin
			load_wait1 <= 0;
		end
end
//first cycle; load ,generate stall; at the end of this cycle mem send out its data
//at the second cycle, load_wait1=1; shut dowm the EA & stall_load=0; and open the reg_en
//third cycle; stall_load =0; new instruction comes ; if new instruction is not lw; fine;
//if it is lw; repeat
//**********************store word*************************
always @(*)
begin
	if(id_opcode == 6'b100001 && store_wait1 ==0) //vstore
		begin
			EA = 32'b0;
			if_stall_store = 1;
			id_stall_store =1;
			memEn =0;
		end
	else if (store_wait1 ==1)
		begin
			EA = {16*{0},id_immediate_address};
			if_stall_store = 0;
			id_stall_store =0;
			memEn =1;
			id_store_register_en =1;
		end
	else 
		begin
			EA = 32'b0;
			if_stall_store = 0;
			id_stall_store =0;
			memEn =0;
			id_store_register_en =0;
		end
end

always @(posedge clk) //first wait & second wait
begin
	if(reset)
		begin
		store_wait1 <=0;
		end
	else if(if_stall_store)
		begin
			store_wait1 <=if_stall_store;
		end
	else 
		begin
			store_wait1 <= 0;
		end
end
//at the first cycle, opcode is store; stall generated; wait1 ==1;read the register
//at the next cycle, wait1==1; give the EA; mem write ; and shut down the stall
//the third cycle, new instrcution comes to ID STAGE; store waits returns to 0;

//****************************id_stage branch related HDU BR to serve the branch related instrctions**********
always @(*)
begin
	if((ex_wb ==1)//singal generated for enable write back to register 
	&& (id_branch_happen) // for the address:0 in register can not be written)
	&& (ex_rd !=0)
	&& (ex_rd == id_rd)) 
	begin
	id_stall_branch =1; //reg type  but it is a wire in fact for choose a mux;
	if_stall_branch =1;
	else
	begin
	id_stall_branch=0;
	if_stall_branch=0;
	end
end


always @(*)
begin
	if (id_opcode == 6'b100010 && ex_rd != id_rd && register[id_rd] ==0 && ex_rd !=0) //vbeq, this is no dependent branch, no stall 
		begin
		load_pc = id_immediate_address;
		pc_en = 1;
		id_branch_happen=1;
		end
	else if (id_opcode == 6'b100010 && ex_rd == id_rd && ex_rd !=0) //vbeq, this is a dependent branch,stall
		begin
		load_pc = id_immediate_address;
		pc_en = 1;
		id_branch_happen=1;
		end
	else if (id_opcode == 6'b100011 && ex_rd != id_rd && register[id_rd] !=0) //vbneq, this is no dependent branch, no stall
	begin
		begin
		load_pc = id_immediate_address;
		pc_en = 1;
		id_branch_happen=1;
		end
	else if(id_opcode == 6'b100011 && ex_rd == id_rd && ex_rd ==0) //vbeq, this is a dependent branch, stall
		begin
		load_pc = id_immediate_address;
		pc_en = 1;
		id_branch_happen=1;	
		end
	else 
		begin
		load_pc = 0;
		pc_en =0;
		id_branch_happen=0;
		end
end

//**********************id_control_logic****************
always @(*)
begin
	id_stall = id_stall_branch | id_stall_load | id_stall_store;
	if_stall = if_stall_branch | if_stall_load | if_stall_store;
end
//***************************************************************	
always @(*)
begin
	if (id_flush==1)
	begin
		id_to_ex_wb = 0;
		id_to_ex_ex = 0;
	end 
	else if (id_flush==0 && id_stall_branch ==1)//generate NOP
	begin
		id_to_ex_wb = 0;
		id_to_ex_ex = 0;	
	end
	else if(id_opcode == 6'b101010) //r-type instructions
	begin
		id_to_ex_wb = 1;
		id_to_ex_ex =1;	
	end
	else //VNOP and branch and lw and sw
	begin
		id_to_ex_wb =0;
		id_to_ex_ex =0;	
	end
end



//*********************************ID_EX_STAGE_REGISTER**************************
always @(posedge clk)
begin
	if(reset)
		begin
				ex_wb <= 0;
				ex_ex <= 0;
				ex_rs <= id_rs;
				ex_rt <= id_rt;
				ex_rs_data <= id_to_ex_read_out1;
				ex_rd <= 0;
				ex_rt_data <= id_to_ex_read_out2;
                ex_function_bits <= 0;
                ex_opcode <= 0;
				ex_ppp <=0;
                ex_ww <= 0;
				ex_shift_amount <= 0;
                ex_immediate_address <= 0;
		end
	else 
		begin
				ex_wb <= id_to_ex_wb;
				ex_ex <= id_to_ex_ex;
				ex_rs <= id_rs;
				ex_rs_data <= id_to_ex_read_out1;
				ex_rd <= id_rd;
				ex_rt <= id_rt;
				ex_rt_data <= id_to_ex_read_out2;
                ex_function_bits <= id_function_bits;
                ex_opcode <= id_opcode;
				ex_ppp <=0;
                ex_ww <= id_ww;
				ex_shift_amount <= id_shift_amount;
                ex_immediate_address <= id_immediate_address;
		end
end
//***************************ex_alu_op_generate*************
always @(*)
begin
	if(ex_ex ==1)
		ex_alu_op =1;
	else 
		ex_alu_op =0;
end
//***************************forward unit in ex stage ***********************
always @(*)
	begin
	if((wb_wb ==1)//singal generated for enable write back to register 
	&& (ex_rd !=0)// for the address:0 in register can not be written)
	&& ((ex_rs == wb_rs) ||(ex_rt == wb_rt))) 
	begin
		FW_RS_WB =1;
	end
	else 
		FW_RS_WB =0;
		
	if((wb_wb ==1)//singal generated for enable write back to register 
	&& (ex_rd !=0)// for the address:0 in register can not be written)
	&& ((ex_rt == wb_rs) ||(ex_rt == wb_rt))) 
	begin
		FW_RT_WB =1;
	end
	else 
		FW_RT_WB =0;
	
end
//**************************ex_mux***********************
always @(*)
begin
	if(FW_RS_WB)
	begin
		if(wb_ppp == 3'b000)
			ex_mux_to_alu1 = wb_data_back;
		else if(wb_ppp == 3'b001)
			ex_mux_to_alu1 = {wb_data_back[0:31],ex_rs_data[32:63]};
		else if(wb_ppp == 3'b010)
			ex_mux_to_alu1 = {ex_rs_data[0:31],wb_data_back[32:63};
		else if(wb_ppp == 3'b011)
			begin
				for (i=0; i<63;i=i+2)
					{ex_mux_to_alu1[i],ex_mux_to_alu1[i+1]} = {wb_data_back[i],ex_rs_data[i+1]};
			end
		else
			begin
				for (i=1; i<64;i=i+2)
					{ex_mux_to_alu1[i-1],ex_mux_to_alu1[i]} = {ex_rs_data[i-1], wb_data_back[i]};
			end
		
	end
	else
		ex_mux_to_alu1 = ex_rs_data;
	
	if(FW_RT_WB)
	begin
		if(wb_ppp == 3'b000)
			ex_mux_to_alu2 = wb_data_back;
		else if(wb_ppp == 3'b001)
			ex_mux_to_alu2 = {wb_data_back[0:31],ex_rt_data[32:63]};
		else if(wb_ppp == 3'b010)
			ex_mux_to_alu2 = {ex_rt_data[0:31],wb_data_back[32:63};
		else if(wb_ppp == 3'b011)
			begin
				for (i=0; i<63;i=i+2)
					{ex_mux_to_alu2[i],ex_mux_to_alu2[i+1]} = {wb_data_back[i],ex_rt_data[i+1]};
			end
		else
			begin
				for (i=1; i<64;i=i+2)
					{ex_mux_to_alu2[i-1],ex_mux_to_alu2[i]} = {ex_rt_data[i-1], wb_data_back[i]};
			end
		
	end
	else
		ex_mux_to_alu2 = ex_rt_data;
end
//*****************************ex_stage_ALU**********************************************************
always @(*)
begin
	if ( ex_alu_op == 0)
		ex_data_back =0;
	else if(ex_function_bits == 6'b000000) //add
		ex_data_back = ex_mux_to_alu1 & ex_mux_to_alu2;
	else if (ex_function_bits == 6'b000001) //vor
		ex_data_back =  ex_mux_to_alu1 | ex_mux_to_alu2;
	else if (ex_function_bits == 6'b000010) // xor
		ex_data_back = ex_mux_to_alu1 ^ ex_mux_to_alu2;
	else if (ex_function_bits == 6'b000011) //vnot
		ex_data_back = ~ex_mux_to_alu1;
	else if (ex_function_bits == 6'b000100) //vmov
		ex_data_back = ex_mux_to_alu1;
	else if (ex_function_bits == 6'b000101) //vaddxy
		begin
			if(ex_ww == 2'b00)
			begin 
				for (i=0; i<=64-8); i= i+8)
					ex_data_back[i:i+7] = ex_mux_to_alu1[i:i+8-1]+ex_mux_to_alu2[i:i+8-1];
			end
			else if(ex_ww == 2'b01)
			begin 
				for (i=0; i<=64-16); i= i+16)
					ex_data_back[i:i+16-1] = ex_mux_to_alu1[i:i+16-1]+ex_mux_to_alu2[i:i+16-1];
			end
			else if(ex_ww == 2'b10)
			begin 
				for (i=0; i<=64-32); i= i+16)
					ex_data_back[i:i+32-1] = ex_mux_to_alu1[i:i+32-1]+ex_mux_to_alu2[i:i+32-1];
			end
			else 
			begin 
					ex_data_back[0:64-1] = ex_mux_to_alu1[0:64-1]+ex_mux_to_alu2[i:i+64-1];
			end
		end 
	else if (ex_function_bits == 6'b000110) //vsubxy
		begin
			if(ex_ww == 2'b00)
			begin 
				for (i=0; i<=64-8); i= i+8)
					ex_data_back[i:i+8-1] = ex_mux_to_alu1[i:i+8-1]+~ex_mux_to_alu2[i:i+8-1]+1;
			end
			else if(ex_ww == 2'b01)
			begin 
				for (i=0; i<=64-16); i= i+16)
					ex_data_back[i:i+16-1] = ex_mux_to_alu1[i:i+16-1]+~ex_mux_to_alu1[i:i+16-1]+1;
			end
			else if(ex_ww == 2'b10)
			begin 
				for (i=0; i<=64-32); i= i+16)
					ex_data_back[i:i+32-1] = ex_mux_to_alu1[i:i+32-1]+~ex_mux_to_alu1[i:i+32-1]+1;
			end
			else 
			begin 
					ex_data_back[0:64-1] = ex_mux_to_alu1[0:64-1]+~ex_mux_to_alu1[i:i+64-1]+1;
			end
		end
	else if (ex_function_bits == 6'b000111) //vmuleuxy
		begin
			if(ex_ww == 2'b00)
			begin 
				for (i=0; i<=64-16); i= i+16)
					ex_data_back[i:i+2*8-1] = ex_mux_to_alu1[i:i+8-1] * ex_mux_to_alu2[i:i+8-1];
			end
			else if(ex_ww == 2'b01)
			begin 
				for (i=0; i<=64-32); i= i+32)
					ex_data_back[i:i+2*16-1] = ex_mux_to_alu1[i:i+16-1] * ex_mux_to_alu1[i:i+16-1];
			end
			else 
			begin 
					ex_data_back = ex_mux_to_alu1[0:31] * ex_mux_to_alu1[0:31];
			end
			
		end 
	else if (ex_function_bits == 6'b001000) //vmulouxy
		begin
			if(ex_ww == 2'b00)
			begin 
				for (i=0; i<=64-16); i= i+16) 
					ex_data_back[i:i+2*8-1] = ex_mux_to_alu1[i+8:i+2*8-1] * ex_mux_to_alu2[i+8:i+2*8-1];
			end
			else if(ex_ww == 2'b01)
			begin 
				for (i=0; i<=64-32); i= i+32)
					ex_data_back[i:i+2*16-1] = ex_mux_to_alu1[i+16:i+32-1] * ex_mux_to_alu1[i+16:i+32-1];
			end
			else 
			begin 
					ex_data_back = ex_mux_to_alu1[32:63] * ex_mux_to_alu1[32:63];
			end
		end 
	else if (ex_function_bits == 6'b001001) //vrtthxy
		begin
			if(ex_ww == 2'b00)
			begin 
				for (i=0; i<=64-8); i= i+8) 
					ex_data_back[i:i+8-1] = {ex_mux_to_alu1[i+4:i+7],ex_mux_to_alu1[i:i+3]};
			end
			else if(ex_ww == 2'b01)
			begin 
				for (i=0; i<=64-16); i= i+16)
					ex_data_back[i:i+16-1] = {ex_mux_to_alu1[i+8:i+15],ex_mux_to_alu1[i:i+7]};
			end
			else if(ex_ww == 2'b10)
			begin 
				for (i=0; i<=64-32); i= i+32)
					ex_data_back[i:i+32-1] = {ex_mux_to_alu1[i+16:i+31],ex_mux_to_alu1[i:i+15]};
			end
			else 
			begin 
					ex_data_back = {ex_mux_to_alu1[i+32:i+63],ex_mux_to_alu1[i:i+31]};
			end
		end 
	else if (ex_function_bits == 6'b001010) //vsllxy
		begin
			if(ex_ww == 2'b00)
			begin 
				for (i=0; i<=64-8); i= i+8) 
					begin
					temp1 = ex_mux_to_alu2[i+5:i+7]
					ex_data_back[i:i+8-1] = {ex_mux_to_alu1[i+temp1:i+7],temp1*{0}};
					end
			end
			else if(ex_ww == 2'b01)
			begin 
				for (i=0; i<=64-16); i= i+16) 
					begin
					temp1 = ex_mux_to_alu2[i+12:i+15]
					ex_data_back[i:i+15] = {ex_mux_to_alu1[i+temp1:i+15],temp1*{0}};
					end
			end
			else if(ex_ww == 2'b10)
			begin 
				for (i=0; i<=64-32); i= i+32) 
					begin
					temp1 = ex_mux_to_alu2[i+27:i+31]
					ex_data_back[i:i+32-1] = {ex_mux_to_alu1[i+temp1:i+31],temp1*{0}};
					end
			end
			else 
			begin 
				for (i=0; i<=64-64); i= i+64) 
					begin
					temp1 = ex_mux_to_alu2[i+58:i+63]
					ex_data_back[i:i+64-1] = {ex_mux_to_alu1[i+temp1:i+63],temp1*{0}};
					end
			end
		end 
	else if (ex_function_bits == 6'b001011) //vsllixy
		begin
			if(ex_ww == 2'b00)
			begin 
				temp1 = ex_shift_amount[2:4]
				for (i=0; i<=64-8); i= i+8) 
					begin
					ex_data_back[i:i+8-1] = {ex_mux_to_alu1[i+temp1:i+7],temp1*{0}};
					end
			end
			else if(ex_ww == 2'b01)
			begin 
				temp1 = ex_shift_amount[1:4]
				for (i=0; i<=64-16); i= i+16) 
					begin
					ex_data_back[i:i+16-1] = {ex_mux_to_alu1[i+temp1:i+15],temp1*{0}};
					end
			end
			else if(ex_ww == 2'b10)
			begin 
				temp1 = ex_shift_amount[0:4]
				for (i=0; i<=64-32); i= i+8) 
					begin
					ex_data_back[i:i+32-1] = {ex_mux_to_alu1[i+temp1:i+31],temp1*{0}};
					end
			end
			else 
			begin 
				temp1 = ex_shift_amount[0:4]
				for (i=0; i<=64-64); i= i+64) 
					begin
					ex_data_back[i:i+64-1] = {ex_mux_to_alu1[i+temp1:i+64],temp1*{0}};
					end
			end
		end 
	else if (ex_function_bits == 6'b001100) //vsrlxy
		begin
			if(ex_ww == 2'b00)
			begin 
				for (i=0; i<=64-8); i= i+8) 
					begin
					temp1 = ex_mux_to_alu2[i+5:i+7]
					ex_data_back[i:i+8-1] = {temp1*{0},ex_mux_to_alu1[i:i+8-temp1-1]};
					end
			end
			else if(ex_ww == 2'b01)
			begin 
				for (i=0; i<=64-16); i= i+16) 
					begin
					temp1 = ex_mux_to_alu2[i+12:i+15]
					ex_data_back[i:i+16-1] = {temp1*{0},ex_mux_to_alu1[i:i+16-temp1-1]};
					end
			end
			else if(ex_ww == 2'b10)
			begin 
				for (i=0; i<=64-32); i= i+32) 
					begin
					temp1 = ex_mux_to_alu2[i+27:i+31]
					ex_data_back[i:i+32-1] = {temp1*{0},ex_mux_to_alu1[i:i+32-temp1-1]};
					end
			end
			else 
			begin 
				for (i=0; i<=64-64); i= i+64) 
					begin
					temp1 = ex_mux_to_alu2[i+58:i+63]
					ex_data_back[i:i+64-1] = {temp1*{0},ex_mux_to_alu1[i:i+64-temp1-1]};
					end
			end
		end 
	else if (ex_function_bits == 6'b001101) //vsrlixy
		begin
			if(ex_ww == 2'b00)
			begin 
				temp1 = ex_shift_amount[2:4]
				for (i=0; i<=64-8); i= i+8) 
					begin
					ex_data_back[i:i+8-1] = {temp1*{0},ex_mux_to_alu1[i:i+7-temp1]};
					end
			end
			else if(ex_ww == 2'b01)
			begin 
				temp1 = ex_shift_amount[1:4]
				for (i=0; i<=64-16); i= i+16) 
					begin
					ex_data_back[i:i+16-1] = {temp1*{0},ex_mux_to_alu1[i:i+16-temp1]};
					end
			end
			else if(ex_ww == 2'b10)
			begin 
				temp1 = ex_shift_amount[0:4]
				for (i=0; i<=64-32); i= i+8) 
					begin
					ex_data_back[i:i+32-1] = {temp1*{0},ex_mux_to_alu1[i:i+32-temp1]};
					end
			end
			else 
			begin 
				temp1 = ex_shift_amount[0:4]
				for (i=0; i<=64-64); i= i+64) 
					begin
					ex_data_back[i:i+64-1] = {temp1*{0},ex_mux_to_alu1[i:i+64-temp1]};
					end
			end
		end 
	else if (ex_function_bits == 6'b001110) //vsraxy
		begin
			if(ex_ww == 2'b00)
			begin 
				for (i=0; i<=64-8); i= i+8) 
					begin
					temp1 = ex_mux_to_alu2[i+5:i+7]
					ex_data_back[i:i+8-1] = {temp1*{ex_mux_to_alu1[i]},ex_mux_to_alu1[i:i+8-temp1-1]};
					end
			end
			else if(ex_ww == 2'b01)
			begin 
				for (i=0; i<=64-16); i= i+16) 
					begin
					temp1 = ex_mux_to_alu2[i+12:i+15]
					ex_data_back[i:i+16-1] = {temp1*{ex_mux_to_alu1[i]},ex_mux_to_alu1[i:i+16-temp1-1]};
					end
			end
			else if(ex_ww == 2'b10)
			begin 
				for (i=0; i<=64-32); i= i+32) 
					begin
					temp1 = ex_mux_to_alu2[i+27:i+31]
					ex_data_back[i:i+32-1] = {temp1*{ex_mux_to_alu1[i]},ex_mux_to_alu1[i:i+32-temp1-1]};
					end
			end
			else 
			begin 
				for (i=0; i<=64-64); i= i+64) 
					begin
					temp1 = ex_mux_to_alu2[i+58:i+63]
					ex_data_back[i:i+64-1] = {temp1*{ex_mux_to_alu1[i]},ex_mux_to_alu1[i:i+64-temp1-1]};
					end
			end
		end 
	else if (ex_function_bits == 6'b001111) //vsraixy
		begin
			if(ex_ww == 2'b00)
			begin 
				temp1 = ex_shift_amount[2:4]
				for (i=0; i<=64-8); i= i+8) 
					begin
					ex_data_back[i:i+8-1] = {temp1*{ex_mux_to_alu1[i]},ex_mux_to_alu1[i:i+7-temp1]};
					end
			end
			else if(ex_ww == 2'b01)
			begin 
				temp1 = ex_shift_amount[1:4]
				for (i=0; i<=64-16); i= i+16) 
					begin
					ex_data_back[i:i+16-1] = {temp1*{ex_mux_to_alu1[i]},ex_mux_to_alu1[i:i+16-temp1]};
					end
			end
			else if(ex_ww == 2'b10)
			begin 
				temp1 = ex_shift_amount[0:4]
				for (i=0; i<=64-32); i= i+8) 
					begin
					ex_data_back[i:i+32-1] = {temp1*{ex_mux_to_alu1[i]},ex_mux_to_alu1[i:i+32-temp1]};
					end
			end
			else 
			begin 
				temp1 = ex_shift_amount[0:4]
				for (i=0; i<=64-64); i= i+64) 
					begin
					ex_data_back[i:i+64-1] = {temp1*{ex_mux_to_alu1[i]},ex_mux_to_alu1[i:i+64-temp1]};
					end
			end
		end 
	else 
	begin
		temp1 = 0;
		ex_data_back = 0;
	end
end

//******************************EX_WB stage**************************
always @(posedge clk)
begin
	if(reset)
	begin
		wb_data_back <=0;
		wb_wb <= 0;
		wb_rd <= 0;
	    wb_ppp <= 0;
        wb_ww <= 0;
	end
	else 
	begin
		wb_data_back <= ex_data_back;
		wb_wb <= ex_wb;
		wb_rd <= ex_rd;
	    wb_ppp <= ex_ppp;
        wb_ww <=  ex_ww;		
	end
end



        
