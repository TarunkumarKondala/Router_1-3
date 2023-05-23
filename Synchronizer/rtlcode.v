`timescale 1ns / 1ps

module SYNCHRONIZER(  input clock, resetn, detect_add, write_enb_reg, 
                      input read_enb0, read_enb1, read_enb2,
                      input empty0, empty1, empty2,
                      input full0, full1, full2,
                      input [1:0]data_in,
                      output vld_out0, vld_out1, vld_out2,
                      output reg[2:0] write_enb,
                      output reg fifo_full,
                      output reg soft_rst0, soft_rst1, soft_rst2
                    );
                    
     reg [4:0] count0, count1, count2;  // counting clock cycles for soft reset
     reg [1:0] data_in_temp;
     
     always@(posedge clock)
     begin
        if(!resetn)
            data_in_temp <= 1'bz;
        else if(detect_add)
            data_in_temp <= data_in;
     end
     
     always@(*)
     begin
        case(data_in_temp)
          2'b00 : begin
                    fifo_full = full0;
                    if(write_enb_reg)
                        write_enb = 3'b001;
                    else
                        write_enb = 0;
                  end
          2'b01 : begin
                    fifo_full = full1;
                    if(write_enb_reg)
                        write_enb = 3'b010;
                    else
                        write_enb = 0;
                  end
          2'b10 : begin
                    fifo_full = full2;
                    if(write_enb_reg)
                        write_enb = 3'b100;
                    else
                        write_enb = 0;
                  end
        default : begin 
                    fifo_full = 0;
                    write_enb = 0;
                  end
      endcase 
     end
     
     assign vld_out0 = ~empty0;
     assign vld_out1 = ~empty1;
     assign vld_out2 = ~empty2;
     
     always@(posedge clock)
     begin
        if(!resetn) begin
            soft_rst0 <= 0;
            count0 <= 0;
        end
        else if(vld_out0 && !read_enb0)
        begin
            if(count0 == 29) begin
                soft_rst0 <= 1;
                count0 <= 0;
            end
            else begin
                soft_rst0 <= 0;
                count0 = count0+1;
            end
       end   
       else count0 = 0;             
    end
    
    always@(posedge clock)
    begin
        if(!resetn) begin
            soft_rst1 <= 0;
            count1 <= 0;
        end
        else if(vld_out1 && !read_enb1)
        begin
            if(count1 == 29) begin
                soft_rst1 <= 1;
                count1 <= 0;
            end
            else begin
                soft_rst1 <= 0;
                count1 = count1+1;
            end
       end  
       else count2 = 0;              
   end
   
   always@(posedge clock)
   begin
       if(!resetn) begin
           soft_rst2 <= 0;
           count2 <= 0;
       end
       else if(vld_out2 && !read_enb2)
       begin
           if(count2 == 29) begin
               soft_rst2 <= 1;
               count2 <= 0;
           end
           else begin
               soft_rst2 <= 0;
               count2 = count2+1;
           end
      end   
      else  count2 = 0;             
  end
endmodule
