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


module Timer_100us_m(
    input clk_i,
    output reg timer_100us_o
    );   
   (* keep="true" *) reg [12:0] div20Khz_cnt;
   
    always@(posedge clk_i)
    begin
        if(div20Khz_cnt<13'd4999)
            div20Khz_cnt<=div20Khz_cnt+1'b1;
        else
            div20Khz_cnt<=0;
    end
    
    always@(posedge clk_i)
    begin
        if(div20Khz_cnt==13'd4999)
            timer_100us_o<=~timer_100us_o;
        else
            timer_100us_o<=timer_100us_o;
    end 
endmodule
