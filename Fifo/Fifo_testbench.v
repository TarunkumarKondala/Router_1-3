`timescale 1ns / 1ps

module FIFO_tb(  );
    reg clock, resetn, write_enb, soft_reset, read_enb;
    reg [7:0] data_in;
    reg lfd_state;
    wire empty, full;
    wire [7:0] data_out;
    
     reg [7:0]payload_data;
     reg [5:0]payload_len;
     reg [7:0]header, parity;
     reg [1:0]addr;
     
     integer i;
    
    FIFO dut( .clock(clock), .resetn(resetn), .soft_reset(soft_reset), .write_enb(write_enb), .read_enb(read_enb),
              .data_in(data_in), .lfd_state(lfd_state), .empty(empty), .full(full), .data_out(data_out));
    
    task initialize();
    begin
       clock=0; write_enb=0; read_enb=0; soft_reset=0; data_in=0; lfd_state=0;
    end
    endtask
    
    task soft_rst();
    begin
        @(negedge clock);
             soft_reset=1;
        @(negedge clock)
             soft_reset=0;
    end
    endtask
    
    task rst();
    begin
        @(negedge clock);
             resetn=0;
        @(negedge clock)
             resetn=1;
    end
    endtask
    
    task pkt_gen();
    begin

         @(negedge clock);
         payload_len=6'd14;
         addr=2'b01;
         header={payload_len,addr};
         data_in=header;
         lfd_state=1'b1; write_enb=1;
         
         for(i=0;i<payload_len;i=i+1)
         begin        
         @(negedge clock);
         lfd_state = 0;
         payload_data={$random}%256;
         data_in=payload_data;
         end
       
         @(negedge clock);
         parity={$random}%256;
         data_in=parity;
    end
    endtask

    
    task pkt_read();
    begin
        write_enb=0; read_enb=1;
    end
    endtask 
    
    always #5 clock = ~clock;
    initial begin
        initialize;
        #10;
        rst;
        #20;
        soft_rst;
        #30;
        initialize;
        #20;
        pkt_gen;
        #200;
        pkt_read();
       
        
        #1000; $finish();
    end
endmodule
