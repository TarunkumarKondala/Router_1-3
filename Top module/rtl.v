module TOP_MODULE(  
          input [7:0]data_in,
          input pkt_valid, clock, resetn,
          input read_enb0,read_enb1,read_enb2,
          output [7:0]data_out0,data_out1,data_out2,
          output vld_out0,vld_out1,vld_out2,err,busy
        );
	
	wire soft_reset0,full0,empty0,
	     soft_reset1,full1,empty1,
	     soft_reset2,full2,empty2,
       fifo_full,
       detect_add,lfd_state,ld_state,full_state,laf_state,rst_int_reg,
       parity_done,low_pkt_valid,write_enb_reg;
         
	wire [2:0]write_enb;
	wire [7:0]d_in;
	
  
    
    // FIFO module instantiation
	
	FIFO FIFO_0( .clock(clock), .resetn(resetn), .soft_reset(soft_reset0),
			         .write_enb(write_enb[0]), .read_enb(read_enb0), .lfd_state(lfd_state),
			         .data_in(d_in), .full(full0), .empty(empty0), .data_out(data_out0));
				   
	FIFO FIFO_1( .clock(clock), .resetn(resetn), .soft_reset(soft_reset1),
               .write_enb(write_enb[1]), .read_enb(read_enb1), .lfd_state(lfd_state),
               .data_in(d_in), .full(full1), .empty(empty1), .data_out(data_out1));
                 
	FIFO FIFO_2( .clock(clock), .resetn(resetn), .soft_reset(soft_reset2),
               .write_enb(write_enb[2]), .read_enb(read_enb2), .lfd_state(lfd_state),
               .data_in(d_in), .full(full2), .empty(empty2), .data_out(data_out2));
                                                 
  			  
  // FSM module instantiation
  
  	FSM FSM0( .clock(clock), .resetn(resetn), .pkt_valid(pkt_valid),
              .data_in(data_in[1:0]),
              .fifo_full(fifo_full),
              .fifo_empty0(empty0), .fifo_empty1(empty1), .fifo_empty2(empty2),
              .soft_reset0(soft_reset0), .soft_reset1(soft_reset1), .soft_reset2(soft_reset2),
              .parity_done(parity_done),
              .low_pkt_valid(low_pkt_valid),
              .write_enb_reg(write_enb_reg),
              .detect_add(detect_add), .ld_state(ld_state), .laf_state(laf_state), .lfd_state(lfd_state),
              .full_state(full_state),
              .rst_int_reg(rst_int_reg),
              .busy(busy));
 
  
  // SYNCHRONIZER module instantiation
  
  						 
       SYNCHRONIZER SYNC(  .clock(clock), .resetn(resetn),
                           .data_in(data_in[1:0]), .detect_add(detect_add),
                           .full0(full0), .full1(full1), .full2(full2),
                           .empty0(empty0), .empty1(empty1), .empty2(empty2),
                           .write_enb_reg(write_enb_reg),
                           .read_enb0(read_enb0), .read_enb1(read_enb1), .read_enb2(read_enb2),
                           .write_enb(write_enb), .fifo_full(fifo_full),
                           .vld_out0(vld_out0), .vld_out1(vld_out1), .vld_out2(vld_out2),
                           .soft_rst0(soft_reset0), .soft_rst1(soft_reset1), .soft_rst2(soft_reset2));                         
      
  // REGISTER module instantiation
  
	REGISTER REG( .clock(clock), .resetn(resetn), .pkt_valid(pkt_valid),
	        	    .data_in(data_in), .fifo_full(fifo_full), .detect_add(detect_add),
                .ld_state(ld_state), .laf_state(laf_state), .full_state(full_state), .lfd_state(lfd_state),
			          .rst_int_reg(rst_int_reg),
			          .err(err),
                .parity_done(parity_done),
			          .low_pkt_valid(low_pkt_valid),
			          .dout(d_in));
				  
endmodule
