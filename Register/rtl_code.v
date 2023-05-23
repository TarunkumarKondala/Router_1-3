`timescale 1ns / 1ps

module REGISTER( input clock, resetn, pkt_valid, 
                 input [7:0] data_in,
                 input fifo_full, rst_int_reg, detect_add,
                 input lfd_state, ld_state, full_state, laf_state,
                 output reg [7:0] dout,
                 output reg parity_done, low_pkt_valid, err
                );
        
      reg [7:0] header, int_reg, internal_parity, external_parity;  // Our actual register
      
      // data out
      always@(posedge clock)
      begin
        if(!resetn) begin
            header <= 0 ;
            dout <= 0;
            int_reg <= 0;
        end
        else if(detect_add && pkt_valid && (data_in[1:0]!=2'b11))
            header <= data_in;
        else if(lfd_state)
            dout <= header;
        else if(ld_state && !fifo_full)
            dout <= data_in;
        else if(ld_state && fifo_full)
            int_reg <= data_in;
        else if(laf_state)
            dout <= int_reg;
      end
      
      // low packet valid
      always@(posedge clock)
      begin
        if(!resetn)
            low_pkt_valid <= 0;
        else if(rst_int_reg)
            low_pkt_valid <= 0;
        else if(ld_state && !pkt_valid)
            low_pkt_valid <= 1;        
      end
      
      // parity done
      always@(posedge clock)
      begin
        if(!resetn)
            parity_done <= 0;
        else if(detect_add)
            parity_done <= 0;
        else if((ld_state && !fifo_full && !pkt_valid)||(laf_state && low_pkt_valid && !parity_done))
            parity_done <= 1;
      end
      
      // internal parity calculation
      always@(posedge clock)
      begin
        if(!resetn || detect_add)
            internal_parity <= 0;
        else if(lfd_state && pkt_valid)
            internal_parity <= internal_parity^header;
        else if(ld_state && pkt_valid && !fifo_full)
            internal_parity <= internal_parity^data_in;
        else
            internal_parity <= internal_parity;
      end
      
      // external parity
      always@(posedge clock)
      begin
        if(!resetn || detect_add)
            external_parity <= 0;
        else if((ld_state && !fifo_full && !pkt_valid)||(laf_state && low_pkt_valid && !parity_done))
            external_parity <= data_in;   
      end
      
      // Error logic
      always@(posedge clock)
      begin
        if(!resetn)
            err <= 0;
        else if(parity_done)
        begin
            if(internal_parity == external_parity)
                err <= 0;
            else
                err <= 1; 
        end
        else
            err <= 0;
      end
endmodule
