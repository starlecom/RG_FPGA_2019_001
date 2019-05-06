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


module Timer_10us_m(
    input clk_i,
    output reg timer_10us_o
    );   
   (* keep="true" *) reg [8:0] div20Khz_cnt;
   
    always@(posedge clk_i)
    begin
        if(div20Khz_cnt<9'd499)
            div20Khz_cnt<=div20Khz_cnt+1'b1;
        else
            div20Khz_cnt<=0;
    end
    
    always@(posedge clk_i)
    begin
        if(div20Khz_cnt==9'd499)
            timer_10us_o<=~timer_10us_o;
        else
            timer_10us_o<=timer_10us_o;
    end 
endmodule

