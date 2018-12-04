module NIC( clk, reset, net_polarity, net_do, net_ro, net_so, net_di, net_ri, net_si, nicEnWr, nicEn, d_out, d_in, addr );
input clk, reset;
input net_polarity;// positive: even negative odd
input net_ro;//ready signal from router
input[1:0] addr;//index 4 kinds of registers in NIC
input[63:0] net_di, d_in; // data from router/ data from processor
input net_si, nicEnWr, nicEn;
output net_ri;
output net_so;
output[63:0] net_do, d_out;


reg[63:0] d_out;
reg input_status, output_status;
wire net_so;
reg net_ri;
reg[63:0] net_data_output;
reg[63:0] temp;

wire[63:0] ALL_ZEROS = {64{1'b0}}; 
wire[3:0] select;
wire[63:0] input_sta, output_sta;
reg[63:0] net_data_input;

assign net_do = net_data_output;
assign net_so = output_status;

always@ ( posedge clk )// from processor --> router
    begin
        if ( reset )
	        begin   
 	            net_data_output <= ALL_ZEROS;
		        //net_so <= 1'b0;
		        output_status <= 1'b0;
		    end
	    else begin  
		    if ( nicEn && nicEnWr && (addr == 2'b00 ) && ( output_status == 1'b0) )
			    begin
			        net_data_output <= d_in;
				    output_status <= 1'b1;
				end 
	        else if (net_ro && (output_status == 1'b1))// for even channel
		        begin
			        //net_so <= 1'b1;
				    output_status <= 1'b0;
			    end
		end
	end
		 

	
assign select = { nicEn, nicEnWr, addr };
assign input_sta = { input_status , {63{1'b0}}} ;
assign output_sta = { output_status , {63{1'b0}}} ;

always@ ( posedge clk )
    begin
	    if ( reset )
		    net_data_input <= ALL_ZEROS;
		else begin
		    if ( net_ri && net_si )
			    net_data_input <= net_di;
		end
	end

always@ ( posedge clk )
    begin
        case( select )
		    4'b1010 : d_out = net_data_input;
		    4'b1001 : d_out = output_sta ;
		    4'b1011 : d_out = input_sta ;
		    default : d_out = ALL_ZEROS;
		endcase
    end

always@ ( posedge clk )
    begin
        if ( reset )
		    begin
                input_status <= 1'b0;
                net_ri <= 1'b1;
			end
		else begin 
		    if ( net_ri && net_si )
			    begin
			        input_status <= 1'b1;
				    net_ri <= 1'b0;
				end
			else if ( nicEn && (!nicEnWr) && ( addr == 2'b10 ) )
			    begin
				    input_status <= 1'b0;
					net_ri <= 1'b1;
				end
		end
	end
		
endmodule		
			
		               					
			
			