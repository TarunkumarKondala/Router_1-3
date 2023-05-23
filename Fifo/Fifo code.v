`timescale 1ns / 1ps

module FIFO(
    input clock, resetn, soft_reset, lfd_state, write_enb, read_enb,
    input [7:0] data_in,
    output wire empty, full,
    output reg [7:0] data_out
        );
    
    reg [8:0]MEM[15:0];    // specified memory (MSB Bit for header check)
    reg [3:0]w_ptr, r_ptr; // pointers for wirte and read operations in queue
    reg [4:0]increment;    // incrementer to know wether the memory full or empty
    reg temp;              // temporary register for lfd_state
    
    reg [5:0]count;
    
    integer i;
    
    //LFD_BIT LOADING...
    always@(posedge clock) begin
        if(!resetn) temp<=0;
        else temp<=lfd_state;
    end
    
    //POINTER LOGIC
    always@(posedge clock) begin
        if(!resetn || soft_reset) begin
            w_ptr<=0;
            r_ptr<=0;
        end
        else begin
            if(read_enb && !empty) r_ptr<=r_ptr+1;
            if(write_enb && !full) w_ptr<=w_ptr+1;
        end
      end
     
     //INCREMENTER_LOGIC
     always@(posedge clock) begin
        if(!resetn || soft_reset) 
                increment=0;
        else if(!full && write_enb)
                increment<=increment+1;
        else if(!empty && read_enb)
                increment<=increment-1;
        else if((!full && write_enb) && (!empty && read_enb))
                increment<=increment;
        else
                increment<=increment;
     end
     
     //FOR WRITE THE DATA INTO THE MEMORY
       always@(posedge clock) begin      
         if(!resetn || soft_reset) begin
           for(i=0; i<16; i=i+1)
               MEM[i]<=0;
         end
         else if(write_enb && !full) begin
                   MEM[w_ptr]<={temp,data_in};
               end
       end
       
       //FOR READ THE DATA FROM THE MEMORY
       always@(posedge clock)
       begin
           if(!resetn)  
                data_out<=0;
           else if(soft_reset) 
                data_out<=8'bz;
           else if(resetn && !soft_reset) begin
                if(read_enb && !empty)
                    data_out<=MEM[r_ptr][7:0];
                else if(count==0)
                    data_out<=8'bz;
           end
        end
       
       //COUNTER LOGIC
       always@(posedge clock)
       begin
          if(!resetn || soft_reset) count<=0;
          if(read_enb && !empty) begin
             if(MEM[r_ptr][8])
                count<=MEM[r_ptr][7:2]+1'b1;
             else if(count!=0)
                count<=count-1;
          end
       end
       
       //FOR THE MEMORY IS EMPTY OR FULL       
       assign full = (increment==16); 
       assign empty = (increment==0);        
                      
endmodule
