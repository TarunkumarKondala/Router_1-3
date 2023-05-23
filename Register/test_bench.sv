`timescale 1ns / 1ps

module REGISTER_tb( );

     reg clock, resetn, pkt_valid; 
     reg [7:0] data_in;
     reg fifo_full, rst_int_reg, detect_add;
     reg lfd_state, ld_state, full_state, laf_state;
     wire [7:0] dout;
     wire parity_done, low_pkt_valid, err;
     
 REGISTER dut (  clock, resetn, pkt_valid, 
                 data_in,
                 fifo_full, rst_int_reg, detect_add,
                 lfd_state, ld_state, full_state, laf_state,
                 dout,
                 parity_done, low_pkt_valid, err
                );
                
    task rst();
    begin
        @(negedge clock)
        resetn=1'b0;
        @(negedge clock)
        resetn=1'b1;
      end
    endtask
                
    task initialize();
      begin
       { clock, data_in, pkt_valid, fifo_full, detect_add, rst_int_reg } = 0;
       { lfd_state, ld_state, full_state, laf_state } = 0;
      end
    endtask
    
                
    task good_pkt_gen_reg; 
    
    reg[7:0]payload_data,parity1,header1;
    reg[5:0]payload_len;
    reg[1:0]addr;
    integer i;    
    begin
     @(negedge clock)
         payload_len=6'd5;
         addr=2'b10;
         pkt_valid=1;
         detect_add=1;
         header1={payload_len,addr};
         parity1=0^header1;
         data_in=header1;
     @(negedge clock);
         detect_add=0;
         lfd_state=1;
         
     for(i=0;i<payload_len;i=i+1)
     begin
     @(negedge clock);
          lfd_state=0;
          ld_state=1;
          payload_data={$random}%256;
          data_in=payload_data;
          parity1=parity1^data_in;
     end
     
     @(negedge clock);
         pkt_valid=0;
         data_in=parity1;
     @(negedge clock);
        ld_state=0;
    end
  endtask
    
                
    task bad_pkt_gen_reg;
    
    reg[7:0]payload_data,parity1,header1;
    reg[5:0]payload_len;
    reg[1:0]addr;
    integer i;
    
    begin
     @(negedge clock)
         payload_len=6'd5;
         addr=2'b10;
         pkt_valid=1;
         detect_add=1;
         header1={payload_len,addr};
         parity1=0^header1;
         data_in=header1;
     @(negedge clock);
     detect_add=0;
     lfd_state=1;
 
     for(i=0;i<payload_len;i=i+1)
     begin
     @(negedge clock);
          lfd_state=0;
          ld_state=1;
          payload_data={$random}%256;
          data_in=payload_data;
          parity1=parity1^data_in;
     end
     @(negedge clock);
         pkt_valid=0;
         data_in=46;
     @(negedge clock);
        ld_state=0;
    end
  endtask
                 
   always #5 clock = ~clock;                 
   initial
    begin                 
         initialize();
         rst();
         good_pkt_gen_reg;
         rst();
         bad_pkt_gen_reg;
         #1000; $finish;
    end                                 
endmodule
