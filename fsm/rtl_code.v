`timescale 1ns / 1ps

module FSM(
    input clock, resetn, pkt_valid, parity_done, fifo_full, low_pkt_valid,
    input soft_reset0, soft_reset1, soft_reset2,
    input fifo_empty0, fifo_empty1, fifo_empty2,
    input [1:0]data_in,  //Destination address
    output busy, detect_addr, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg, lfd_state
 );
 
 parameter DECODE_ADDRESS=0, WAIT_TILL_EMPTY=1, LOAD_FIRST_DATA=2, LOAD_DATA=3,
           LOAD_PARITY=4, CHECK_PARITY_ERROR=5, FIFO_FULL_STATE=6, LOAD_AFTER_FULL=7;
 
 reg [2:0]PS, NS;
 
 always@(posedge clock)
 begin
    if(!resetn)
        PS<=DECODE_ADDRESS;
    else if(( soft_reset0 && data_in[1:0]==0 ) ||
            ( soft_reset1 && data_in[1:0]==1 ) ||
            ( soft_reset2 && data_in[1:0]==2 ))
         PS<=DECODE_ADDRESS;        
    else
        PS<=NS;
 end
 
 //State logic
 always@(*)
 begin
    case(PS)
        DECODE_ADDRESS : if(( pkt_valid && (data_in[1:0]==0) && fifo_empty0 ) ||
                            ( pkt_valid && (data_in[1:0]==1) && fifo_empty1 ) ||
                            ( pkt_valid && (data_in[1:0]==2) && fifo_empty2 ))
                                        NS=LOAD_FIRST_DATA;
                         else if(( pkt_valid && (data_in[1:0]==0) && !fifo_empty0 ) ||
                                 ( pkt_valid && (data_in[1:0]==1) && !fifo_empty1 ) ||
                                 ( pkt_valid && (data_in[1:0]==2) && !fifo_empty2 ))
                                        NS=WAIT_TILL_EMPTY;
                         else           NS=DECODE_ADDRESS;
                         
       WAIT_TILL_EMPTY : if(( fifo_empty0 && (data_in[1:0]==0) ) ||
                            ( fifo_empty1 && (data_in[1:0]==1) ) ||
                            ( fifo_empty2 && (data_in[1:0]==2) ))
                                        NS=LOAD_FIRST_DATA;
                         else           NS=WAIT_TILL_EMPTY;
    
       LOAD_FIRST_DATA :                NS=LOAD_DATA;
      
             LOAD_DATA : if( !fifo_full && !pkt_valid )
                                        NS=LOAD_PARITY;
                         else if( fifo_full)
                                        NS=FIFO_FULL_STATE;
                         else           NS=LOAD_DATA;
                         
           LOAD_PARITY :                NS=CHECK_PARITY_ERROR;
           
    CHECK_PARITY_ERROR : if( fifo_full )
                                        NS=FIFO_FULL_STATE;
                         else
                                        NS=DECODE_ADDRESS;
                     
       FIFO_FULL_STATE : if( !fifo_full )
                                        NS=LOAD_AFTER_FULL;
                         else if( fifo_full )
                                        NS=FIFO_FULL_STATE;
             
       LOAD_AFTER_FULL : if ( !parity_done && low_pkt_valid )
                                        NS=LOAD_PARITY;
                         else if ( !parity_done && !low_pkt_valid )
                                        NS=LOAD_DATA;
                         else if ( parity_done )
                                        NS=DECODE_ADDRESS; 
               default :                NS=DECODE_ADDRESS;
           
     endcase                                                                           
 end
 
 //Output logic  busy, detect_addr, lfd_state, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg 
assign busy = (PS==WAIT_TILL_EMPTY) || (PS==LOAD_FIRST_DATA) || (PS==LOAD_PARITY) || (PS==CHECK_PARITY_ERROR) ||
              (PS==FIFO_FULL_STATE) || (PS==LOAD_AFTER_FULL);
assign detect_addr = (PS==DECODE_ADDRESS);
assign lfd_state = (PS==LOAD_FIRST_DATA);
assign ld_state = (PS==LOAD_DATA);
assign laf_state = (PS==LOAD_AFTER_FULL);
assign full_state = (PS==FIFO_FULL_STATE);
assign write_enb_reg = (PS==LOAD_DATA) || (PS==LOAD_PARITY) || (PS==LOAD_AFTER_FULL); //(PS== LOAD_FIRST_DATA) 
assign rst_int_reg = (PS==CHECK_PARITY_ERROR);
        
endmodule
