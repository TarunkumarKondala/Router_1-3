`timescale 1ns / 1ps

module SYNCHRONIZER_tb(  );
        
        reg clock, resetn, detect_add, write_enb_reg;
        reg read_enb0, read_enb1, read_enb2;
        reg empty0, empty1, empty2;
        reg full0, full1, full2;
        reg [1:0]data_in;
        wire vld_out0, vld_out1, vld_out2;
        wire [2:0] write_enb;
        wire fifo_full;
        wire soft_rst0, soft_rst1, soft_rst2;
        
  SYNCHRONIZER dut ( clock, resetn, detect_add, write_enb_reg, 
                     read_enb0, read_enb1, read_enb2,
                     empty0, empty1, empty2,
                     full0, full1, full2,
                     data_in,
                     vld_out0, vld_out1, vld_out2,
                     write_enb, fifo_full,
                     soft_rst0, soft_rst1, soft_rst2 
                    );
                    
   task initialize;
   begin
        { clock, detect_add, data_in, write_enb_reg } = 0;
        { read_enb0, read_enb1, read_enb2 } = 0;
        { empty0, empty1, empty2 } = 0;
        { full0, full1, full2 } = 0;        
   end
   endtask
   
   task rst;
   begin
        @(negedge clock) resetn = 0;
        @(negedge clock) resetn = 1;
   end
   endtask
   
   task detect_address (input [1:0]di,input detect_addr);
   begin
        data_in=di;
        detect_add=detect_addr;
   end
   endtask
   
   task read_enable ( input r0, r1, r2 );
   begin        
        read_enb0 = r0;
        read_enb1 = r1;
        read_enb2 = r2;
   end
   endtask
   
   task full ( input f0, f1, f2 );
   begin
        full0 = f0;
        full1 = f1;
        full2 = f2;
   end
   endtask 
   
   task empty ( input e0, e1, e2 );
   begin      
        empty0 = e0;
        empty1 = e1;
        empty2 = e2;
   end
   endtask
   
   always #5 clock = ~clock;
   initial begin
       initialize;
       #10;
       rst;
       #20;
       @(negedge clock);
       detect_address(2'b10,1);
       read_enable(1,0,1);
       full(0,0,0);
       empty(0,0,0);
       write_enb_reg=1;  
       
       #1000; $finish();
   end
endmodule
