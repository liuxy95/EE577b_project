module cmp(
	input CLK,
	input RESET,
	//***********************///////
	input[0:31] node0_inst_in,
	input[0:63] node0_d_in,
	output[0:31] node0_pc_out,
	output[0:31] node0_addr_out,
	output[0:63] node0_d_out,
	output node0_memWrEn, 
	output node0_memEn,
	//output[0:1] node0_addr_nic,
	//output[0:63] node0_din_nic, 
	//output[0:63] node0_dout_nic,
	//output node0_nicEn, 
	//output node0_nicWrEn,
	//****************************************************//
	input[0:31] node1_inst_in,
	input[0:63] node1_d_in,
	output[0:31] node1_pc_out,
	output[0:31] node1_addr_out,
	output[0:63] node1_d_out,
	output node1_memWrEn, 
	output node1_memEn,
	/*output[0:1] node1_addr_nic,
	output[0:63] node1_din_nic, 
	output[0:63] node1_dout_nic,
	output node1_nicEn, 
	output node1_nicWrEn,*/
	//****************************************************//
	input[0:31] node2_inst_in,
	input[0:63] node2_d_in,
	output[0:31] node2_pc_out,
	output[0:31] node2_addr_out,
	output[0:63] node2_d_out,
	output node2_memWrEn, 
	output node2_memEn,
	/*output[0:1] node2_addr_nic,
	output[0:63] node2_din_nic, 
	output[0:63] node2_dout_nic,
	output node2_nicEn, 
	output node2_nicWrEn,*/
	//****************************************************//
	input[0:31] node3_inst_in,
	input[0:63] node3_d_in,
	output[0:31] node3_pc_out,
	output[0:31] node3_addr_out,
	output[0:63] node3_d_out,
	output node3_memWrEn, 
	output node3_memEn
	/*output[0:1] node3_addr_nic,
	output[0:63] node3_din_nic, 
	output[0:63] node3_dout_nic,
	output node3_nicEn, 
	output node3_nicWrEn*/
);

wire[0:31]	p0_dmemAddr,p1_dmemAddr,p2_dmemAddr,p3_dmemAddr; // processorX data memory address
wire p0_memEn,p0_memWrEn;	// processorX mem/nic access Enable and Write Enable
wire p1_memEn,p1_memWrEn;
wire p2_memEn,p2_memWrEn;
wire p3_memEn,p3_memWrEn;

wire polarity0,polarity1,polarity2,polarity3;
wire r0_pesi,r0_peri,r0_peso,r0_pero;
wire[0:63] r0_pedi,r0_pedo;
wire r1_pesi,r1_peri,r1_peso,r1_pero;
wire[0:63] r1_pedi,r1_pedo;
wire r2_pesi,r2_peri,r2_peso,r2_pero;
wire[0:63] r2_pedi,r2_pedo;
wire r3_pesi,r3_peri,r3_peso,r3_pero;
wire[0:63] r3_pedi,r3_pedo;

wire nic0_WrEn,nic1_WrEn,nic2_WrEn,nic3_WrEn;
wire nic0_En,nic1_En,nic2_En,nic3_En;

wire[0:63] nic0_dout,nic1_dout,nic2_dout,nic3_dout;
wire[0:63] nic0_din,nic1_din,nic2_din,nic3_din;

wire[0:63] p0_din,p1_din,p2_din,p3_din;
/////////////////////////////////////////////////////////////////////////////////
/*assign node0_addr_nic = node0_addr_out[30:31];
assign node1_addr_nic = node1_addr_out[30:31];
assign node2_addr_nic = node2_addr_out[30:31];
assign node3_addr_nic = node3_addr_out[30:31];

assign node0_din_nic = nic0_din;
assign node1_din_nic = nic1_din;
assign node2_din_nic = nic2_din;
assign node3_din_nic = nic3_din;

assign node0_dout_nic = nic0_dout;
assign node1_dout_nic = nic1_dout;
assign node2_dout_nic = nic2_dout;
assign node3_dout_nic = nic3_dout;*/

assign nic0_En = p0_memEn && (node0_addr_out[16:17]==2'b11); // nic access enable active when processor memEn and address[16:17]=11
assign nic1_En = p1_memEn && (node1_addr_out[16:17]==2'b11);
assign nic2_En = p2_memEn && (node2_addr_out[16:17]==2'b11);
assign nic3_En = p3_memEn && (node3_addr_out[16:17]==2'b11);
assign nic0_WrEn = p0_memWrEn && (node0_addr_out[16:17]==2'b11);
assign nic1_WrEn = p1_memWrEn && (node1_addr_out[16:17]==2'b11);
assign nic2_WrEn = p2_memWrEn && (node2_addr_out[16:17]==2'b11);
assign nic3_WrEn = p3_memWrEn && (node3_addr_out[16:17]==2'b11);

assign p0_din = nic0_En ? nic0_dout : node0_d_in;
assign p1_din = nic1_En ? nic1_dout : node1_d_in;
assign p2_din = nic2_En ? nic2_dout : node2_d_in;
assign p3_din = nic3_En ? nic3_dout : node3_d_in;

cardinal_processor p0(CLK,RESET,node0_inst_in,p0_din,node0_pc_out,node0_d_out,node0_addr_out,p0_memEn,p0_memWrEn);
cardinal_processor p1(CLK,RESET,node1_inst_in,p1_din,node1_pc_out,node1_d_out,node1_addr_out,p1_memEn,p1_memWrEn);
cardinal_processor p2(CLK,RESET,node2_inst_in,p2_din,node2_pc_out,node2_d_out,node2_addr_out,p2_memEn,p2_memWrEn);
cardinal_processor p3(CLK,RESET,node3_inst_in,p3_din,node3_pc_out,node3_d_out,node3_addr_out,p3_memEn,p3_memWrEn);

assign node0_memEn = p0_memEn;
assign node1_memEn = p1_memEn;
assign node2_memEn = p2_memEn;
assign node3_memEn = p3_memEn;
assign node0_memWrEn = p0_memWrEn;
assign node1_memWrEn = p1_memWrEn;
assign node2_memWrEn = p2_memWrEn;
assign node3_memWrEn = p3_memWrEn;

/*assign node0_nicEn = nic0_En;
assign node1_nicEn = nic1_En;
assign node2_nicEn = nic2_En;
assign node3_nicEn = nic3_En;
assign node0_nicWrEn = nic0_WrEn;
assign node1_nicWrEn = nic1_WrEn;
assign node2_nicWrEn = nic2_WrEn;
assign node3_nicWrEn = nic3_WrEn;*/

assign nic0_din = node0_d_out;
assign nic1_din = node1_d_out;
assign nic2_din = node2_d_out;
assign nic3_din = node3_d_out;

NIC	nic0(CLK,RESET,polarity0,r0_pedi,r0_peri,r0_pesi,r0_pedo,r0_pero,r0_peso,nic0_WrEn,nic0_En,nic0_dout,nic0_din,node0_addr_out[30:31]);
NIC	nic1(CLK,RESET,polarity1,r1_pedi,r1_peri,r1_pesi,r1_pedo,r1_pero,r1_peso,nic1_WrEn,nic1_En,nic1_dout,nic1_din,node1_addr_out[30:31]);
NIC	nic2(CLK,RESET,polarity2,r2_pedi,r2_peri,r2_pesi,r2_pedo,r2_pero,r2_peso,nic2_WrEn,nic2_En,nic2_dout,nic2_din,node2_addr_out[30:31]);
NIC	nic3(CLK,RESET,polarity3,r3_pedi,r3_peri,r3_pesi,r3_pedo,r3_pero,r3_peso,nic3_WrEn,nic3_En,nic3_dout,nic3_din,node3_addr_out[30:31]);

router_ring_4  router(CLK,RESET,polarity0,polarity1,polarity2,polarity3,
						r0_pesi,r0_peri,r0_pedi,r1_pesi,r1_peri,r1_pedi,
						r2_pesi,r2_peri,r2_pedi,r3_pesi,r3_peri,r3_pedi,
						r0_peso,r0_pero,r0_pedo,r1_peso,r1_pero,r1_pedo,
						r2_peso,r2_pero,r2_pedo,r3_peso,r3_pero,r3_pedo);

endmodule









