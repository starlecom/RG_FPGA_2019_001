`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/24 14:47:44
// Design Name: 
// Module Name: Timer_10us_m
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Timer_1us_m(
    input clk_i,
    output reg timer_1us_o
    );   
   (* keep="true" *) reg [5:0] div2Mhz_cnt;
   
    always@(posedge clk_i)
    begin
        if(div2Mhz_cnt<6'd49)
            div2Mhz_cnt<=div2Mhz_cnt+1'b1;
        else
            div2Mhz_cnt<=0;
    end
    
    always@(posedge clk_i)
    begin
        if(div2Mhz_cnt==6'd49)
            timer_1us_o<=~timer_1us_o;
        else
            timer_1us_o<=timer_1us_o;
    end 
endmodule
