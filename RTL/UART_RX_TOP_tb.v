`timescale 1ns/1ps
module UART_RX_TOP_tb();
 /* DUT Signals */
 reg        CLK_tb,RST_tb;
 reg        RX_IN_tb;
 reg  [4:0] PRESCALE_tb;
 reg        PAR_EN_tb,PAR_TYP_tb;
 wire [7:0] P_DATA_tb;
 wire       DATA_VALID_tb;
 
 localparam CLK_Period = 5.0 ;  // f = 200 MHz
 localparam even       = 0   ;
 localparam odd        = 1   ;
 integer    i                ;
 
 /* Initial Block */
 initial
  begin
   $dumpfile("UART_RX_TOP.vcd");     
   $dumpvars;       
   initialize();
   reset();
   
   $display("TEST DATA WITH EVEN PARITY");
   data_even_parity(11'b0_1001_0101_1_1);     
   wait(DATA_VALID_tb)
   if(P_DATA_tb==8'b1010_1001)   
    $display("DATA WITH EVEN PARITY PASSED");
   else
    $display("DATA WITH EVEN PARITY FAILED");
	
   $display("TEST DATA WITH ODD PARITY");
   data_odd_parity(11'b0_1101_0101_1_1);     
   wait(DATA_VALID_tb)
   if(P_DATA_tb==8'b1010_1011)   
    $display("DATA WITH ODD PARITY PASSED");
   else
    $display("DATA WITH ODD PARITY FAILED");
	
   $display("TEST DATA WITH NO PARITY");
   data_no_parity(10'b0_1001_0111_1);     
   wait(DATA_VALID_tb)
   if(P_DATA_tb==8'b1110_1001)   
    $display("DATA WITH NO PARITY PASSED");
   else
    $display("DATA WITH NO PARITY FAILED");
	
   $display("TEST WRONG FRAME");
   wrong_frame(11'b0_1001_0101_1_1);     
   if(P_DATA_tb!=8'b1010_1111)   
    $display("WRONG FRAME PASSED");
   else
    $display("WRONG FRAME FAILED");
   
   #10 $finish;
  end
 
 /* Tasks */
 task initialize;
  begin
   CLK_tb      = 0 ;
   RST_tb      = 1 ;
   RX_IN_tb    = 1 ;
   PRESCALE_tb = 8 ;
   PAR_EN_tb   = 0 ;
   PAR_TYP_tb  = 0 ;
  end
 endtask
 
 task reset;
  begin
   #CLK_Period
   RST_tb = 0  ;
   #CLK_Period
   RST_tb = 1  ;
   #CLK_Period ;
  end
 endtask
 
 task data_even_parity;
  input [10:0] FRAME_PAR ;
  begin
   PAR_EN_tb = 1;
   PAR_TYP_tb = even;
   for (i=10 ; i>-1 ; i=i-1)
    begin
	 RX_IN_tb = FRAME_PAR[i]   ;
	 #(CLK_Period*PRESCALE_tb) ; 
    end
  end
 endtask
 
 task data_odd_parity;
  input [10:0] FRAME_PAR ;
  begin
   PAR_EN_tb = 1;
   PAR_TYP_tb = odd;
   for (i=10 ; i>-1 ; i=i-1)
    begin
	 RX_IN_tb = FRAME_PAR[i]   ;
	 #(CLK_Period*PRESCALE_tb) ; 
    end
  end
 endtask
 
 task data_no_parity;
  input [9:0]  FRAME_NPAR ;
  begin
   PAR_EN_tb = 0;
   for (i=9 ; i>-1 ; i=i-1)
    begin
	 RX_IN_tb = FRAME_NPAR[i]   ;
	 #(CLK_Period*PRESCALE_tb) ; 
    end
  end
 endtask
 
 task wrong_frame;
  input [10:0] FRAME_PAR ;
  begin
   PAR_EN_tb = 0;
   for (i=10 ; i>-1 ; i=i-1)
    begin
	 RX_IN_tb = FRAME_PAR[i]   ;
	 #(CLK_Period*PRESCALE_tb) ; 
    end
  end
 endtask
 
 always #(CLK_Period/2) CLK_tb = ~ CLK_tb ; 
 
 /* DUT Instantiation */
 UART_RX_TOP DUT (
 .RX_IN(RX_IN_tb),
 .PRESCALE(PRESCALE_tb),
 .PAR_EN(PAR_EN_tb),
 .PAR_TYP(PAR_TYP_tb),
 .CLK(CLK_tb),
 .RST(RST_tb),
 .P_DATA(P_DATA_tb),
 .DATA_VALID(DATA_VALID_tb) 
 );

endmodule
