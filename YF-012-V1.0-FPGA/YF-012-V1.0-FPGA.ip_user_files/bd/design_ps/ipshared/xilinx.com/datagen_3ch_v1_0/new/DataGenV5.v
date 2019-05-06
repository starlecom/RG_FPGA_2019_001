`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/09/29 15:35:16
// Design Name:
// Module Name: DataGenV5
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


module DataGenV5(
    input clk,
    input rst,
    input signed [15:0] hf_ch,          //真实信号
    input [15:0] hf_ch_sim,         //仿真信号
    input [3:0] sw_ch_out,          //传输的通道号
    input [63:0] global_cnt,        //全局计数器
    input signed [15:0] trig_level,        //触发电平
    input signed [15:0] trig_level_l,        //触发电平低
    input [15:0] pretrig,           //预触发深度
    input [15:0] trig_length,       //触发总深度

    input src_sel,
    input DataGen_ready,            //1 表示参数配置完毕 可以开始采集
    input s_axis_start,             //启动传输信号，1为启动传输 0为等待
    output reg send_busy,               //1表示正在传输，0表示停止传输
    input S_AXIS_tready,
    output hf_ch_send_flag,         //状态输出标志，1表示数据准备就绪可以发送
    output reg [15:0] S_AXIS_tdata,
    output S_AXIS_tvalid,
    output reg S_AXIS_tlast

    );

(* keep="true" *) reg hf_ch_send_flag,S_AXIS_tvalid;   
(* keep="true" *) wire s_axis_start,S_AXIS_tready,DataGen_ready; 
//ILA  clk
//wire [31:0] ls_probe0,ls_probe1,ls_probe2,ls_probe3,ls_probe4;
//ila_0 mila_ls (
//  .clk(clk), // input wire clk
//
//
//  .probe0(ls_probe0), // input wire [31:0]  probe0
//  .probe1(ls_probe1), // input wire [31:0]  probe1
//  .probe2(ls_probe2), // input wire [31:0]  probe2
//  .probe3(ls_probe3), // input wire [31:0]  probe3
//  .probe4(ls_probe4) // input wire [31:0]  probe4
//);
//assign ls_probe0[15:0]=hf_sig;
//assign ls_probe0[31:16]=prififo_dout;
//assign ls_probe1[0]=prififo_wr_en;
//assign ls_probe1[1]=prififo_rd_en;
//assign ls_probe1[2]=prififo_empty;
//assign ls_probe1[3]=prififo_full;
//assign ls_probe1[4]=mfifo_wr_en;
//assign ls_probe1[5]=mfifo_rd_en;
//assign ls_probe1[6]=mfifo_empty;
//assign ls_probe1[7]=mfifo_full;
//assign ls_probe1[11:8]=hf_ch_sample_state;
//assign ls_probe1[12]=hf_ch_send_flag;
//assign ls_probe1[13]=DataGen_ready;
//assign ls_probe1[14]=S_AXIS_tready;
//assign ls_probe1[15]=send_flag_t;
//assign ls_probe1[31:16]=mfifo_cnt;
//
//assign ls_probe2[15:0]=mfifo_din;
//
//assign ls_probe2[16]=send_flag_tt;
//assign ls_probe2[31:17]=32'd0;
//
//assign ls_probe3[31:0]=32'd0;
//assign ls_probe4[31:0]=32'd0;
//信号源选择
(* keep="true" *)reg signed [15:0] hf_sig;
(* keep="true" *)wire signed [15:0] hf_sig_fir;
(* keep="true" *)reg prififo_wr_en,prififo_rd_en;
(* keep="true" *)wire [15:0] prififo_dout;
(* keep="true" *)wire prififo_full,prififo_empty;
always @(posedge clk)
    if (!rst) begin
        hf_sig<=16'd0;
    end else begin
        if (src_sel==0)
            hf_sig<=hf_ch_sim; 
        else
            hf_sig<=(hf_ch);
    end
    
fir_compiler_0 fir_lowpass
(
    .aclk                 (clk),
    .s_axis_data_tvalid   (1'b1),
    .s_axis_data_tready   (s_tready),
    .s_axis_data_tdata    (hf_sig),
    .m_axis_data_tvalid   (),
    .m_axis_data_tdata    (hf_sig_fir)
); 
//预触发FIFO
pretrig_fifo prefifo (
  .clk(clk),      // input wire clk
  .srst(1'b0),     // input wire srst
  .din(hf_sig_fir),   // input wire [15 : 0] din
  .wr_en(prififo_wr_en),  // input wire wr_en
  .rd_en(prififo_rd_en),  // input wire rd_en
  .dout(prififo_dout),    // output wire [15 : 0] dout
  .full(prififo_full),    // output wire full
  .empty(prififo_empty)   // output wire empty
);

//主FIFO
wire [15:0] mfifo_dout;
(* keep="true" *)reg [15:0] mfifo_din;
(* keep="true" *)reg mfifo_wr_en,mfifo_rd_en;
(* keep="true" *)wire mfifo_full,mfifo_empty,mfifo_almost_empty,mfifo_almost_full;

(* keep="true" *)reg [3:0] send_state;

fifo_generator_0 mfifo (
  .wr_clk(clk),              // input wire wr_clk
  .rd_clk(clk),              // input wire 
  .din(mfifo_din),                    // input wire [15 : 0] din
  .wr_en(mfifo_wr_en),                // input wire wr_en
  .rd_en(mfifo_rd_en),                // input wire rd_en
  .dout(mfifo_dout),                  // output wire [15 : 0] dout
  .almost_full(mfifo_almost_full),    // output wire almost_full
  .full(mfifo_full),                  // output wire full
  .empty(mfifo_empty),                // output wire empty
  .almost_empty(mfifo_almost_empty)  // output wire almost_empty
);
//写数据
reg [15:0] pre_cnt;
(* keep="true" *) reg [15:0] mfifo_cnt;
(* keep="true" *) reg [15:0] pre_fifo_num;    //预触发FIFO中的数据量
(* keep="true" *)reg [3:0] hf_ch_sample_state=4'd0;
(* keep="true" *)reg [15:0] pretrig_bk; 
always @(posedge clk)
    if (!rst) begin
        pre_fifo_num<=16'd0;
        mfifo_din<=16'd0;
    end else begin
        //产生pre_fifo_num，记录prefifo中的数据量
        if (prififo_wr_en==1)
            if (prififo_rd_en==0)
                if(prififo_full==0)
                    pre_fifo_num<=pre_fifo_num+1;
                else
                    pre_fifo_num<=pre_fifo_num;
            else
                pre_fifo_num<=pre_fifo_num;
        else
            if (prififo_rd_en==1)
                if(prififo_empty==0)
                    pre_fifo_num<=pre_fifo_num-1;
                else
                    pre_fifo_num<=pre_fifo_num;
            else
                pre_fifo_num<=pre_fifo_num;

         //写数据
         case (hf_ch_sample_state)
               4'b0000 : begin
                          if (pretrig < pretrig_bk)
                            begin
                             if (pre_fifo_num>=(pretrig-1))
                                begin
                                prififo_wr_en<=1'b0;
                                prififo_rd_en<=1'b1;
                                end
                             else 
                                begin
                                pretrig_bk<=pretrig;
                                end
                            end
                          else
                            begin
                            if(pretrig_bk==0)
                               pretrig_bk<=pretrig;
                            hf_ch_sample_state<=4'b0001; 
                            end
                         end
               4'b0001 : begin
                        if (DataGen_ready==1)
                            if (pre_fifo_num<(pretrig-1))
                                begin
                                prififo_wr_en<=1'b1;
                                prififo_rd_en<=1'b0;
                                end
                            else
                                begin
                                hf_ch_sample_state<=4'b0010;
                                prififo_rd_en<=1'b1;
                                pretrig_bk<=pretrig;
                                end
                        else
                            hf_ch_sample_state<=4'b0001;
                        end
               4'b0010 : begin
                        if ((hf_sig_fir>=trig_level)||(hf_sig_fir<=(trig_level_l)))
                            begin
                            hf_ch_sample_state<=4'b0011;
                            mfifo_din<=prififo_dout;
                            mfifo_wr_en<=1'b1; 
                            end
                        else
                            begin
                            prififo_rd_en<=1'b1;    // 同时读写，保持FIFO中数据量
                            mfifo_din<=16'd0;                            
                            end
                        end
               4'b0011 : begin                        
                        if (mfifo_cnt<1001)
                            begin
                            mfifo_wr_en<=1'b1;
                            mfifo_din<=prififo_dout;
                            hf_ch_send_flag<=1'b0;
                            hf_ch_sample_state<=4'b0011; 
                            mfifo_cnt<=mfifo_cnt+1;
                            end
                        else
                            begin
                            mfifo_wr_en<=1'b0;      //主FIFO填充完毕
                            hf_ch_send_flag<=1'b1;
                            hf_ch_sample_state<=4'b0100;                         
                            end
                        end
               4'b0100 : begin
                        send_flag_tt<=send_flag_t;
                        if ((send_flag_tt==1)&&(send_flag_t==0))
                            begin
                            hf_ch_sample_state<=4'b0000; 
                            hf_ch_send_flag<=1'b0;
                            mfifo_cnt<=16'd0;
                            end
                        else
                            hf_ch_sample_state<=4'b0100;
                                
                        if (send_flag_t==1)
                            hf_ch_send_flag<=1'b0;                            
                        end


         endcase
    end

(* keep="true" *) reg [3:0] header_cnt;
reg [31:0] packet_header=32'hA5A51234;
reg [31:0] packet_tail=32'h12345678;

(* keep="true" *) reg send_flag_t;
(* keep="true" *) reg send_flag_tt;
(* keep="true" *) reg [15:0] rd_cnt;

always @(posedge clk)
    begin
      send_busy<=send_flag_t;
      case (send_state)
      4'b0000 : begin
        if ((hf_ch_send_flag==1)&&(s_axis_start==1))
          begin
          send_state<=4'b0001;
          send_flag_t<=1'b1;
          end
        else
          begin
          send_state<=send_state;
          mfifo_rd_en<=1'b0;
          end
        end
      4'b0001 : begin   //发送数据头
        if (S_AXIS_tready==1)
          begin
          S_AXIS_tvalid<=1'b1;
          S_AXIS_tlast<=1'b0;
          case (header_cnt)
          4'b0000 : begin S_AXIS_tdata<=packet_header[31 : 16];header_cnt<=4'b0001; end
  
          4'b0001 : begin S_AXIS_tdata<=packet_header[15 : 0];header_cnt<=4'b0010; end
  
          4'b0010 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b0011; end
  
          4'b0011 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b0100; end
  
          4'b0100 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b0101; end
  
          4'b0101 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b0110; end
  
          4'b0110 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b0111; end
  
          4'b0111 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b1000; end
  
          4'b1000 : begin S_AXIS_tdata<={12'h000,sw_ch_out};header_cnt<=4'b1001; end
  
          4'b1001 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b1010; end
  
          4'b1010 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b1011; end
  
          4'b1011 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b1100; mfifo_rd_en<=1'b1;end
  
          4'b1100 : begin
                    S_AXIS_tdata<=mfifo_dout;                  
                    send_state<=4'b0010;
                    header_cnt<=4'b0000;
                    end
          endcase
          end
        else 
          begin
          S_AXIS_tdata<=S_AXIS_tdata;
          send_state<=4'b0001;
          end
        end
      4'b0010 : begin   //发送数据 
        if (S_AXIS_tready==1)
          begin     
          if (rd_cnt<1000)
            begin
              send_state<=4'b0010;
              mfifo_rd_en<=1'b1;
              S_AXIS_tdata<=mfifo_dout;
              rd_cnt<=rd_cnt+1;
            end
          else
            begin
              mfifo_rd_en<=1'b0;
              case (header_cnt)
              4'b0000 : begin S_AXIS_tdata<=global_cnt[63 : 48];header_cnt<=4'b0001; end
      
              4'b0001 : begin S_AXIS_tdata<=global_cnt[47 : 32];header_cnt<=4'b0010; end
      
              4'b0010 : begin S_AXIS_tdata<=global_cnt[31 : 16];header_cnt<=4'b0011; end
      
              4'b0011 : begin S_AXIS_tdata<=global_cnt[15 : 0];header_cnt<=4'b0100; end
      
              4'b0100 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b0101; end
      
              4'b0101 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b0110; end
      
              4'b0110 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b0111; end
      
              4'b0111 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b1000; end
      
              4'b1000 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b1001; end
      
              4'b1001 : begin S_AXIS_tdata<=packet_tail[31 : 16];header_cnt<=4'b1010; end
      
              4'b1010 : begin S_AXIS_tdata<=packet_tail[15 : 0];header_cnt<=4'b1011; S_AXIS_tlast<=1'b1;end
      
              4'b1011 : begin S_AXIS_tdata<=16'd0;header_cnt<=4'b1100; S_AXIS_tlast<=1'b0;S_AXIS_tvalid<=1'b0;end
      
              4'b1100 : begin
                        S_AXIS_tdata<=16'd0;
                        send_state<=4'b0011;
                        header_cnt<=4'b0000;
                        rd_cnt<=16'd0;
                        end
              endcase
            end
          end
        else
          begin
          S_AXIS_tdata<=S_AXIS_tdata;
          send_state<=4'b0010;            
          end
      end
      4'b0011 : begin   //发送数据    
        if  (S_AXIS_tready==1)        //传输完毕
          begin
          S_AXIS_tlast<=1'b0;
          S_AXIS_tvalid<=1'b0;
          send_state<=4'b0000; 
          send_flag_t<=1'b0;  
                 
          end
        else
          begin
          //S_AXIS_tlast<=1'b1;
          //S_AXIS_tvalid<=1'b1;           
          send_state<=4'b0011;
          end                     
        end
        
      endcase
    end


endmodule
