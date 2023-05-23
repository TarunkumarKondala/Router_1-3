`timescale 1ns / 1ps

module TOP_MODULE_tb(  );
     reg [7:0]data_in;
     reg pkt_valid, clock, resetn;
     reg read_enb0,read_enb1,read_enb2;
     wire [7:0]data_out0,data_out1,data_out2;
     wire vld_out0,vld_out1,vld_out2,err,busy;
     
     TOP_MODULE TOP ( data_in, pkt_valid, clock, resetn, read_enb0, read_enb1, read_enb2,
                      data_out0, data_out1, data_out2, vld_out0, vld_out1, vld_out2, err, busy);
     
     task initialize();
     begin
        { clock, pkt_valid, data_in, read_enb0, read_enb1, read_enb2 } = 0;
        resetn = 1;
     end
     endtask
     
     task rst();
     begin
        @(negedge clock) resetn <= 0;
        @(negedge clock) resetn <=1;
     end
     endtask
     
     task pkt1();   // packet having payload length 5
        reg [7:0]header, payload_data, parity;
        reg [5:0]payload_len;
        reg [1:0]addr;
        integer i;
     begin
         parity=0;
         wait(!busy)
         begin
             @(negedge clock);
             payload_len=5;
             addr=2'b10;
             pkt_valid=1'b1;
             header={payload_len,addr};
             data_in=header;
             parity=parity^data_in;
         end
         
         @(negedge clock);
         for(i=0;i<payload_len;i=i+1)
         begin
             wait(!busy)                
             @(negedge clock);
             payload_data={$random}%256;
             data_in=payload_data;
             parity=parity^data_in;                
         end  
         
         wait(!busy)				
             @(negedge clock);
             pkt_valid=0;                
             data_in=parity;  
             
         repeat(30)@(negedge clock) 
             read_enb2=1'b1;
     end
     endtask
     
     
     
     task pkt2();   // packet having payload length 14
             reg [7:0]header, payload_data, parity;
             reg [5:0]payload_len;
             reg [1:0]addr;
             integer i;
          begin
              parity=0;
              wait(!busy)
              begin
                  @(negedge clock);
                  payload_len=14;
                  addr=2'b00;
                  pkt_valid=1'b1;
                  header={payload_len,addr};
                  data_in=header;
                  parity=parity^data_in;
              end
              
              @(negedge clock);
              for(i=0;i<payload_len;i=i+1)
              begin
                  wait(!busy)                
                  @(negedge clock);
                  payload_data={$random}%256;
                  data_in=payload_data;
                  parity=parity^data_in;                
              end  
              
              wait(!busy)                
                  @(negedge clock);
                  pkt_valid=0;                
                  data_in=parity;  
                  
              repeat(30)@(negedge clock) 
                  read_enb0=1'b1;
          end
          endtask
          
          
          
          task pkt3();   // packet having payload length 20
                  reg [7:0]header, payload_data, parity;
                  reg [5:0]payload_len;
                  reg [1:0]addr;
                  integer i;
               begin
                   parity=0;
                   wait(!busy)
                   begin
                       @(negedge clock);
                       payload_len=5;
                       addr=2'b10;
                       pkt_valid=1'b1;
                       header={payload_len,addr};
                       data_in=header;
                       parity=parity^data_in;
                   end
                   
                   @(negedge clock);
                   for(i=0;i<payload_len;i=i+1)
                   begin
                       wait(!busy)                
                       @(negedge clock);
                       payload_data={$random}%256;
                       data_in=payload_data;
                       parity=parity^data_in;                
                   end  
                   
                   wait(!busy)                
                       @(negedge clock);
                       pkt_valid=0;                
                       data_in=parity;  
                       
                   repeat(30)@(negedge clock) 
                       read_enb2=1'b1;
               end
               endtask
               
        always #5 clock = ~clock;
        initial begin
               
        initialize();
        #10;
        rst();
        #10;
        pkt1();
        #10;
        pkt2();
        #10;
        pkt3();
        
        #1000; $finish();                
        end
     
endmodule
