`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/11 10:45:37
// Design Name: 
// Module Name: DataGen_3ch
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


module DataGen_3ch(
    input clk,
    input rst,
    //信号输入
    input signed [15:0] hf_ch1,
    input signed [15:0] hf_ch2,
    input signed [15:0] hf_ch3,
    //触发信号
    input signed [15:0] trig_level_h_ch1,
    input signed [15:0] trig_level_l_ch1,
    input signed [15:0] trig_level_h_ch2,
    input signed [15:0] trig_level_l_ch2,
    input signed [15:0] trig_level_h_ch3,
    input signed [15:0] trig_level_l_ch3,
    input [15:0] pretrig,
    input [15:0] trig_length,
    //测试脉冲信号控制
    input [31:0] dds_config_data,
    input [15:0] pulse_period,
    input [15:0] pulse_offset,
    input [15:0] pulse_width,
    //校零
    input signed [15:0] adjusted_value, 
    //信号源选择
    input src_sel,
    input [3:0] ch_sel,
    input DataGen_ready,		//1 表示参数配置完毕 可以开始采集
    //AXIS总线
    output reg hf_ch_send_flag,
    input S_AXIS_start,
    output S_AXIS_aclk,
    output S_AXIS_aresetn,
    input S_AXIS_tready,
    output reg [15:0]  S_AXIS_tdata,
    output [1:0] S_AXIS_tkeep,
    output reg S_AXIS_tvalid,
    output reg S_AXIS_tlast

    );
    
//wire clk;    
//IBUFGDS mclkbuf (.I (clk_p),.IB (clk_n),.O (clk));

(* keep="true" *) reg signed [13:0] hf_ch1_r,hf_ch2_r,hf_ch3_r;

(* keep="true" *) reg signed [15:0] hf_ch1_rr,hf_ch2_rr,hf_ch3_rr;
(* keep="true" *) reg [13:0] tmp_rand1_r,tmp_rand2_r,tmp_rand3_r;
always @(posedge clk)
	begin
		hf_ch1_r<=hf_ch1[15:2];
		hf_ch2_r<=hf_ch2[15:2];
		hf_ch3_r<=hf_ch3[15:2];
		
    if (hf_ch1[2]==0) tmp_rand1_r<=16'd0; else  tmp_rand1_r<=16'hffff;
    if (hf_ch2[2]==0) tmp_rand2_r<=16'd0; else  tmp_rand2_r<=16'hffff;
    if (hf_ch3[2]==0) tmp_rand3_r<=16'd0; else  tmp_rand3_r<=16'hffff;
       
	  hf_ch1_rr<=({hf_ch1_r[13:1]^tmp_rand1_r[13:1],tmp_rand1_r[0],2'b00}+adjusted_value);
	  hf_ch2_rr<=({hf_ch2_r[13:1]^tmp_rand2_r[13:1],tmp_rand2_r[0],2'b00}+adjusted_value);
	  hf_ch3_rr<=({hf_ch3_r[13:1]^tmp_rand3_r[13:1],tmp_rand3_r[0],2'b00}+adjusted_value);
		  
	end
	
assign S_AXIS_aresetn=rst;
assign S_AXIS_aclk=clk;
assign S_AXIS_tkeep=2'b11; 
//dds
wire [15:0] dds_sin;
(* keep="true" *)reg [15:0] hf_ch_sim;
(* keep="true" *)reg [15:0] hf_ch_sim_cnt;

//reg [31:0] dds_config_data=32'h0199999A;    
dds_compiler_0 mdds (
  .aclk(clk),                               // input wire aclk
  .s_axis_config_tvalid(1'b1),              // input wire s_axis_config_tvalid
  .s_axis_config_tdata(dds_config_data),    // input wire [31 : 0] s_axis_config_tdata
  .m_axis_data_tvalid(),                    // output wire m_axis_data_tvalid
  .m_axis_data_tdata(dds_sin)               // output wire [15 : 0] m_axis_data_tdata
);

//产生全局时钟计数器
reg [63:0] global_cnt=0;
always @(posedge clk)
    if (!rst) 
     begin
      global_cnt <= 0;
     end 
    else 
     begin
       global_cnt <= global_cnt+1;
       if(global_cnt>=64'hffff_ffff_ffff_ffff)
       begin
       global_cnt <= 0;
       end
     end

//选择输出通道
reg [15:0] wait_cnt =16'd0;
always @(posedge clk)
    if (!rst) begin
	    ch1_S_AXIS_start<=1'b0;
	    ch2_S_AXIS_start<=1'b0;
	    ch3_S_AXIS_start<=1'b0;
	    hf_ch_send_flag <=1'b0;    //状态输出标志，1表示数据准备就绪可以发送 
	                      
	    S_AXIS_tdata    <=16'd0; 
	    S_AXIS_tvalid   <=1'b0;
	    S_AXIS_tlast    <=1'b0;
	    sw_ch_state     <=4'd0;
	    sw_ch_out       <=4'd0;             
    end else begin
    	if (S_AXIS_start==1)
    	begin	    	 
	     	case (sw_ch_state)
	     	4'b0000 : 
	     		begin
	     		if ((hf_ch1_send_flag==1)&&(ch_sel[0]==1))
	     			begin
						sw_ch_out       <=  4'b0001;     //指示当前传输的通道
						sw_ch_state     <=  4'b0001;
						ch1_S_AXIS_start<=  1'b1;
						ch1_send_busy_t <=  1'b0;
						end
					else if ((hf_ch2_send_flag==1)&&(ch_sel[1]==1))
	     			begin
						sw_ch_out       <=  4'b0010;     //指示当前传输的通道
						sw_ch_state     <=  4'b0001;
						ch2_S_AXIS_start<=  1'b1;
						ch2_send_busy_t <=  1'b0;
						end				
					else if ((hf_ch3_send_flag==1)&&(ch_sel[2]==1))
	     			begin
						sw_ch_out       <=  4'b0011;     //指示当前传输的通道
						sw_ch_state     <=  4'b0001;
						ch3_S_AXIS_start<=  1'b1;
						ch3_send_busy_t <=  1'b0;
						end					
					else
						begin
	          ch1_S_AXIS_start<=1'b0;
	          ch2_S_AXIS_start<=1'b0;
	          ch3_S_AXIS_start<=1'b0;
	          ch1_S_AXIS_tready   <=1'b0;
	          ch2_S_AXIS_tready   <=1'b0;
	          ch3_S_AXIS_tready   <=1'b0;
	          hf_ch_send_flag <=1'b0;         //状态输出标志，1表示数据准备就绪可以发送 
	
	          S_AXIS_tdata    <=16'd0;
	          S_AXIS_tvalid   <=1'b0;
	          S_AXIS_tlast    <=1'b0;
	          sw_ch_state     <=4'b0000;
	          sw_ch_out       <=4'b0000;					
						end
	     		end	
	     	4'b0001 : 
	     		begin
	     		if (sw_ch_out==4'b0001)
	     			begin 
	     			ch1_send_busy_t<=ch1_send_busy;
	     			if ((ch1_send_busy_t==1)&&(ch1_send_busy==0))
	     				begin
	     				sw_ch_state<=4'b0010; 
	     				ch1_S_AXIS_start<=1'b0; 
	     				end   				
	     			else
	     				begin
	            hf_ch_send_flag <=  hf_ch1_send_flag;
	
	            ch1_S_AXIS_tready   <= S_AXIS_tready;
	            S_AXIS_tdata    <=  ch1_S_AXIS_tdata;
	            S_AXIS_tvalid   <=  ch1_S_AXIS_tvalid;
	            S_AXIS_tlast    <=  ch1_S_AXIS_tlast; 
	          	end     				
	     			end    			
	     		else if (sw_ch_out==4'b0010)	
	    			begin 
	     			ch2_send_busy_t<=ch2_send_busy;
	     			if ((ch2_send_busy_t==1)&&(ch2_send_busy==0))
	     				begin
	     				sw_ch_state<=4'b0010;
	     				ch2_S_AXIS_start<=1'b0;
	     				end
	     			else
	     				begin
	            hf_ch_send_flag <=  hf_ch2_send_flag;
	
	            ch2_S_AXIS_tready<= S_AXIS_tready;
	            S_AXIS_tdata    <=  ch2_S_AXIS_tdata;
	            S_AXIS_tvalid   <=  ch2_S_AXIS_tvalid;
	            S_AXIS_tlast    <=  ch2_S_AXIS_tlast; 
	          	end     				
	     			end     		
	     		
	     		
	     		else if (sw_ch_out==4'b0011)	
	    			begin 
	     			ch3_send_busy_t<=ch3_send_busy;
	     			if ((ch3_send_busy_t==1)&&(ch3_send_busy==0))
	     				begin
	     				sw_ch_state<=4'b0010;
	     				ch3_S_AXIS_start<=1'b0;
	     				end
	     			else
	     				begin
	            hf_ch_send_flag <=  hf_ch3_send_flag;
	
	            ch3_S_AXIS_tready<= S_AXIS_tready;
	            S_AXIS_tdata    <=  ch3_S_AXIS_tdata;
	            S_AXIS_tvalid   <=  ch3_S_AXIS_tvalid;
	            S_AXIS_tlast    <=  ch3_S_AXIS_tlast; 
	          	end     				
	     			end
	     		else
	     			sw_ch_state     <=  4'b0001;      			
	     		end	 
	     	4'b0010 : 
	     		begin
	     		if (wait_cnt<1 )
	     			begin
          	wait_cnt<=wait_cnt+1;
		        ch1_S_AXIS_start	<=1'b0;
		        ch2_S_AXIS_start	<=1'b0;
		        ch3_S_AXIS_start	<=1'b0;
		        ch1_S_AXIS_tready <=1'b0;
		        ch2_S_AXIS_tready <=1'b0;
		        ch3_S_AXIS_tready <=1'b0;
		        hf_ch_send_flag 	<=1'b0;                   //状态输出标志，1表示数据准备就绪可以发送 
		                            
		        S_AXIS_tdata    	<=16'd0; 
		        S_AXIS_tvalid   	<=1'b0;
		        S_AXIS_tlast    	<=1'b0;
		        sw_ch_state     	<=4'b0010;
		      	end
         	else
          	begin
            wait_cnt<=16'd0;	     			
		        sw_ch_state     	<=4'b0000;
		        sw_ch_out       	<=4'b0000; 
	        	end    			
	     		end   	
	    	endcase
	    end
    end
    

//产生测试波形
reg [15:0] pulse_cnt=0;
//reg [15:0] pulse_period =16'd2000;         //产生的脉冲信号周期
//reg [15:0] pulse_offset =16'd100;          //产生的脉冲信号偏移相位
//reg [15:0] pulse_width =16'd100;           //产生的脉冲信号宽度  				
always @(posedge clk)
    if (!rst) begin
       pulse_cnt<=0;
       hf_ch_sim<=16'd0;
    end else begin
       if (pulse_cnt<pulse_period)
            pulse_cnt<=pulse_cnt+1;
       else
            pulse_cnt<=0;
       if((pulse_cnt>pulse_offset) && (pulse_cnt<(pulse_offset+pulse_width) ) )
            hf_ch_sim<=dds_sin;
       else
            hf_ch_sim<=16'd0;
    end

(* keep="true" *) reg [3:0] sw_ch_out;
(* keep="true" *) reg [3:0] sw_ch_state;
   
DataGenV5 hf_sig_ch1(
    .clk(clk),
    .rst(rst),
    .hf_ch(hf_ch1_rr),             //真实信号
    .hf_ch_sim(hf_ch_sim),         //仿真信号
    .sw_ch_out(sw_ch_out),          //传输的通道号
    .global_cnt(global_cnt),        //全局计数器
    .trig_level(trig_level_h_ch1),        //触发电平
    .trig_level_l(trig_level_l_ch1),        //触发电平
    .pretrig(pretrig),           //预触发深度
    .trig_length(trig_length),       //触发总深度

    .src_sel(src_sel),
    .DataGen_ready(DataGen_ready),        //1 表示参数配置完毕 可以开始采集
    .s_axis_start(ch1_S_AXIS_start),             //启动传输信号，1为启动传输 0为等待
    .send_busy(ch1_send_busy),								//1表示正在传输，0表示停止传输
    .S_AXIS_tready(ch1_S_AXIS_tready),
    .hf_ch_send_flag(hf_ch1_send_flag),         //状态输出标志，1表示数据准备就绪可以发送 
    .S_AXIS_tdata(ch1_S_AXIS_tdata),
    .S_AXIS_tvalid(ch1_S_AXIS_tvalid),
    .S_AXIS_tlast(ch1_S_AXIS_tlast)
    
    );    

(* keep="true" *) reg ch1_S_AXIS_start;
(* keep="true" *) reg ch1_S_AXIS_tready;
(* keep="true" *) wire hf_ch1_send_flag;
(* keep="true" *) wire [15:0]  ch1_S_AXIS_tdata;
(* keep="true" *) wire ch1_S_AXIS_tvalid;
(* keep="true" *) wire ch1_S_AXIS_tlast;

(* keep="true" *) reg ch2_S_AXIS_start;
(* keep="true" *) reg ch2_S_AXIS_tready;
(* keep="true" *) wire hf_ch2_send_flag;
(* keep="true" *) wire [15:0]  ch2_S_AXIS_tdata;
(* keep="true" *) wire ch2_S_AXIS_tvalid;
(* keep="true" *) wire ch2_S_AXIS_tlast;
 
(* keep="true" *) reg ch3_S_AXIS_start;
(* keep="true" *) reg ch3_S_AXIS_tready;
(* keep="true" *) wire hf_ch3_send_flag;
(* keep="true" *) wire [15:0]  ch3_S_AXIS_tdata;
(* keep="true" *) wire ch3_S_AXIS_tvalid;
(* keep="true" *) wire ch3_S_AXIS_tlast;

(* keep="true" *) wire ch1_send_busy,ch2_send_busy,ch3_send_busy;
(* keep="true" *) reg ch1_send_busy_t,ch2_send_busy_t,ch3_send_busy_t;
        
DataGenV5 hf_sig_ch2(
    .clk(clk),
    .rst(rst),
    .hf_ch(hf_ch2_rr),             //真实信号
    .hf_ch_sim(hf_ch_sim),         //仿真信号
    .sw_ch_out(sw_ch_out),          //传输的通道号
    .global_cnt(global_cnt),        //全局计数器
    .trig_level(trig_level_h_ch2),        //触发电平
    .trig_level_l(trig_level_l_ch2),        //触发电平
    .pretrig(pretrig),           //预触发深度
    .trig_length(trig_length),       //触发总深度

    .src_sel(src_sel),
    .DataGen_ready(DataGen_ready),        //1 表示参数配置完毕 可以开始采集
    .s_axis_start(ch2_S_AXIS_start),             //启动传输信号，1为启动传输 0为等待
    .send_busy(ch2_send_busy),								//1表示正在传输，0表示停止传输    
    .S_AXIS_tready(ch2_S_AXIS_tready),
    .hf_ch_send_flag(hf_ch2_send_flag),         //状态输出标志，1表示数据准备就绪可以发送 
    .S_AXIS_tdata(ch2_S_AXIS_tdata),
    .S_AXIS_tvalid(ch2_S_AXIS_tvalid),
    .S_AXIS_tlast(ch2_S_AXIS_tlast)
    
    );  
    
DataGenV5 hf_sig_ch3(
    .clk(clk),
    .rst(rst),
    .hf_ch(hf_ch3_rr),             		//真实信号
    .hf_ch_sim(hf_ch_sim),      //仿真信号
    .sw_ch_out(sw_ch_out),          //传输的通道号
    .global_cnt(global_cnt),        //全局计数器
    .trig_level(trig_level_h_ch3),        //触发电平
    .trig_level_l(trig_level_l_ch3),        //触发电平
    .pretrig(pretrig),           		//预触发深度
    .trig_length(trig_length),      //触发总深度

    .src_sel(src_sel),
    .DataGen_ready(DataGen_ready),        //1 表示参数配置完毕 可以开始采集
    .s_axis_start(ch3_S_AXIS_start),        //启动传输信号，1为启动传输 0为等待
    .send_busy(ch3_send_busy),								//1表示正在传输，0表示停止传输    
    .S_AXIS_tready(ch3_S_AXIS_tready),
    .hf_ch_send_flag(hf_ch3_send_flag),     //状态输出标志，1表示数据准备就绪可以发送 
    .S_AXIS_tdata(ch3_S_AXIS_tdata),
    .S_AXIS_tvalid(ch3_S_AXIS_tvalid),
    .S_AXIS_tlast(ch3_S_AXIS_tlast)
    
    );      
endmodule
