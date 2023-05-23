`timescale 1ns / 1ps

module FSM_tb(   );
   reg clock, resetn, pkt_valid, parity_done, fifo_full, low_pkt_valid;
   reg soft_reset0, soft_reset1, soft_reset2;
   reg fifo_empty0, fifo_empty1, fifo_empty2;
   reg [1:0]data_in;
   wire busy, detect_addr, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg, lfd_state;
   
   FSM dut(  clock, resetn, pkt_valid, parity_done, fifo_full, low_pkt_valid,
             soft_reset0, soft_reset1, soft_reset2,
             fifo_empty0, fifo_empty1, fifo_empty2,
             data_in,
             busy, detect_addr, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg, lfd_state 
          );
   
   task initialize;
   begin
        { clock, pkt_valid, resetn, pkt_valid, parity_done, fifo_full, low_pkt_valid } = 0;
        { soft_reset0, soft_reset1, soft_reset2, fifo_empty0, fifo_empty1, fifo_empty2 } = 0;
   end
   endtask
   
   task rst;
   begin
     @(negedge clock)
       resetn = 0;
     @(negedge clock)
       resetn = 1;
   end
   endtask
   
  task task1;
  begin
    @(negedge clock)  // LFD
      begin
      pkt_valid<=1;
      data_in[1:0]<=0;
      fifo_empty0<=1;
      end              
    @(negedge clock) //LD
    @(negedge clock) //LP
      begin
      fifo_full<=0;
      pkt_valid<=0;
      end
    @(negedge clock) // CPE
    @(negedge clock) // DA
      fifo_full<=0;
  end
  endtask
  
  task task2;
    begin
     @(negedge clock)//LFD
         begin
         pkt_valid<=1;
         data_in[1:0]<=1;
         fifo_empty1<=1;
         end
     @(negedge clock)//LD
     @(negedge clock)//FFS
        fifo_full<=1;
     @(negedge clock)//LAF
        fifo_full<=0;
     @(negedge clock)//LP
         begin
         parity_done<=0;
         low_pkt_valid<=1;
         pkt_valid<=0;
         end
     @(negedge clock)//CPE
     @(negedge clock)//DA
        fifo_full<=0;
    end
  endtask
  
  task task3;
   begin
     @(negedge clock) //LFD
       begin
       pkt_valid<=1;
       data_in[1:0]<=0;
       fifo_empty0<=1;
       end
    @(negedge clock) // LD
    @(negedge clock) // FFS
       fifo_full<=1;
    @(negedge clock) // LAF
       fifo_full<=0;
    @(negedge clock)  // LD
       begin
        low_pkt_valid<=0;
        parity_done<=0;    
       end  
    @(negedge clock) // LP
       begin
        fifo_full<=0;
        pkt_valid<=0;
       end
   @(negedge clock) // CPE
   @(negedge clock) // DA
       fifo_full<=0;
   end
   endtask
   
   task task4;
    begin
      @(negedge clock)  // LFD
        begin
          pkt_valid<=1;
          data_in[1:0]<=2;
          fifo_empty2<=1;
        end        
      @(negedge clock)   // LD
      @(negedge clock)   // LP
        begin
          fifo_full<=0;
          pkt_valid<=0;
        end
      @(negedge clock)   // CPE 
      @(negedge clock)   // FFS
         fifo_full<=1;
      @(negedge clock)   // LAF
         fifo_full<=0;
     @(negedge clock)    // DA
         parity_done=1;
    end
   endtask
   
   always #5 clock = ~clock;
   initial begin
   initialize;
   #10;
   rst;
   #30;
   task1;
   rst;
   #30;
   task2;
   rst;
   #30;
   task3;
   rst;
   #30;
   task4;
   rst;
   
   #1000; $finish();
   end

endmodule
