
`timescale 1ns/1ps
module Convolution( CLK, RESET,
IN DATA 1,
IN DATA 2,
IN DATA 3,
IN VALID, KERNEL_VALID, KERNEL,
OUT DATA, OUT_VALID
);
input CLK, RESET;
input IN_VALID, KERNEL_VALID;
input [4:0] IN_DATA_1, IN_DATA_2, IN_DATA_3;
input signed [7:0]KERNEL;
output reg[31:0] OUT_DATA;
output reg OUT_VALID;
  
//Write Your Design Here
reg [4:0] datal_buf [0:6]; //save 7 data reg [4:0] data2_buf [0:13]; //save 14 data reg [4:0] data3_buf [0:20]; //save 21 data reg signed [11:0] conv1_ch1_mul [0:6]; reg signed [12:0] conv1_ch1_add1 [0:3];
reg signed [13:0] conv1_ch1_add2 [0:1];
reg signed [14:0] conv1_ch1_buf [0:6]; //save 7 data
reg signed [11:0] conv1_ch2_mul [0:6];
reg signed [12:0] conv1_ch2_add1 [0:3];
reg signed [13:0] conv1_ch2_add2 [0:1];
reg signed [14:0] conv1_ch2_buf [0:6]; //save 7 data
reg signed [11:0] conv1_ch3_mul [0:6]; 
reg signed [12:0] conv1_ch3_add1 [0:3];
reg signed [13:0] conv1_ch3_add2 [0:1];
reg signed [14:0] conv1_ch3_buf [0:6]; // save 7 data
reg signed [15:0] out_ch1_mul [0:6]; 
reg signed [15:0] out_ch1_add1 [0:3]; 
reg signed [15:0] out_ch1_add2 [0:1]; 
reg signed [15:0] out_ch1_tmp;
reg signed [15:0] out_ch2_mul [0:6];


reg signed [15:0] out_ch2_add1 [0:3]; 
reg signed [15:0] out_ch2_add2 [0:1]; 
reg signed [15:0] out_ch2_tmp;
reg signed [15:0] out_ch3_mul [0:6]; 
reg signed [15:0] out_ch3_add1 [0:3]; 
reg signed [15:0] out_ch3_add2 [0:1]; 
reg signed [15:0] out_ch3_tmp;
reg [15:0] out_ch1_buf [0:13]; //save 14 data3 
reg [15:0] out_ch2_buf [0:6]; //save 7 data
reg signed [31:0] point_wisel_tmp; 
reg signed [31:0] point_wise2_tmp; 
reg signed [31:0] point_wise3_tmp; 
reg [31:0] point_wise_sum;
reg [6:0] counter; // MAX num is 99
reg [2:0] kernel_idx1;
reg [4:0] datal_idx, data2_idx, data3_idx; //max (datal_idx): 6 max(ch2_idx): 13 max(ch3_idx): 20
reg [3:0] conv1_ch1_idx, conv1_ch2_idx, conv1_ch3_idx, out_ch1_idx, out_ch2_idx;
reg signed [7:0] kernel1 [0:6]; 
reg signed [7:0] kernel2 [0:6]; 
reg signed [7:0] kernel3 [0:6]; 
reg signed [7:0] point_wisel; 
reg signed [7:0] point_wise2;
reg signed [7:0] point_wise3;
reg [2:0] current_state, next_state;
parameter INIT = 0, WAIT = 1, MUL_KER = 2, EXPORT = 3, END = 4;
always @(*) begin
case (current_state)
INIT: next_state =(RESET == 1'd0)? WAIT INIT;
WAIT: next state = (IN_VALID == 1'd1) ? MUL_KER: WAIT; 
MUL_KER: next_state= (counter == 7'd36) ? EXPORT : MUL_KER; 
EXPORT: next_state= (counter == 7'd124) ? INIT: EXPORT; 
default: next_state= INIT;
endcase
end

always @(posedge CLK or posedge RESET) begin
if (RESET)
  OUT_VALID <=1'b0;
else if (current_state== EXPORT)
  OUT_VALID <=1'b1;
else
  OUT_VALID <=1'b0;
end


always @(posedge CLK or posedge RESET) 
if (RESET)
  current_state <= INIT;
else
  current_state <= next_state;

always @(posedge CLK or posedge RESET) begin
if (RESET)
  point_wisel <<= 8'd0;
else if(current_state== MUL_KER && counter == 7'd21)
  point_wisel <= KERNEL;
else
  point_wisel <= point_wisel;

always @(posedge CLK or posedge RESET) begin
if (RESET)
  point_wise2 <= 8'd0;
else if (current_state== MUL_KER && counter ==7'd22)
  point_wise2 <= KERNEL;
else
  point_wise2 <= point_wise2;
end

always @(posedge CLK or posedge RESET) begin 
if (RESET)
  point_wise3 <= 8'd0;
else if (current_state== MUL_KER && counter == 7'd23)
  point_wise3<< KERNEL;
else
  point_wise3 <= point_wise3;
end

always @(posedge CLK or posedge RESET) begin
if (RESET)
  datal idx <= 5'd0;
else if(IN_VALID == 1'b1) begin
  if(datal idx != 5'd7)
    datal idx <= datal_idx + 5'd1;
  else
    datal_idx <= datal_idx;
end
else
 datal_idx <= datal_idx;
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  datal_buf[0] <= 5'd0;
  datal buf[1] <= 5'd0;
  datal buf[2] <= 5'd0;
  datal_buf[3] <= 5'd0;
  datal_buf[4] <= 5'd0;
  datal buf[5] <= 5'd0;
  datal_buf[6] <= 5'd0;
end
else if (KERNEL_VALID || IN_VALID) begin 
  if (datal_idx < 5'd7)
    datal_buf[datal_idx] <= IN_DATA_1;
  else begin
    datal_buf[0] <= datal_buf[1]; 
    datal buf[1] <= datal_buf[2];
    datal_buf[2] <= datal_buf[3];
    datal_buf[3] <= datal_buf[4]; 
    datal_buf[4] <= datal_buf[5]; 
    datal buf[5] <= datal_buf[6]; 
    datal_buf[6] <= IN_DATA_1;
  end
end
else begin
  datal_buf[0] <= datal_buf[1]; 
  datal buf[1] <= datal_buf[2]; 
  datal_buf[2] <= datal_buf[3]; 
  datal buf[3] <= datal_buf[4]; 
  datal_buf[4] <= datal_buf[5]; 
  datal_buf[5] <= datal_buf[6]; 
  datal_buf[6] <= 5'd0;
end
end

always @(posedge CLK or posedge RESET) begin 
if (RESET)
  data2_idx <= 5'd0;
else if(IN VALID == 1'b1) begin
  if(data2_idx != 5'd14)
    data2_idx <= data2_idx + 5'd1;
  else
    data2_idx <= data2_idx;
end
else
  data2_idx <= data2_idx;
end


always @(posedge_CLK or posedge RESET) begin 
if (RESET) begin
  data2_buf[0] <= 5'd0; 
  data2_buf[1] <= 5'd0; 
  data2_buf[2] <= 5'd0; 
  data2_buf[3] <= 5'd0; 
  data2_buf[4] <= 5'd0; 
  data2_buf[5] <= 5'd0; 
  data2_buf[6] <= 5'd0; 
  data2_buf[7] <= 5'd0; 
  data2_buf[8] <= 5'd0; 
  data2_buf[9] <= 5'd0; 
  data2_buf[10] <= 5'd0; 
  data2_buf[11] <= 5'd0; 
  data2_buf[12] <= 5'd0; 
  data2_buf[13] <= 5'd0;
end
else if (KERNEL_VALID || IN_VALID) begin
  if(data2 idx != 5'd14)
    data2_buf[data2_idx] <= IN_DATA_2; 
  else begin
    data2_buf[0] <= data2_buf[1]; 
    data2_buf[1] <= data2_buf[2]; 
    data2_buf[2] <= data2_buf[3]; 
    data2_buf[3] <= data2_buf[4]; 
    data2_buf[4] <= data2_buf[5]; 
    data2_buf[5] <= data2_buf[6]; 
    data2 buf[6] <= data2_buf[7]; 
    data2_buf[7] <= data2_buf[8]; 
    data2_buf[8] <= data2_buf[9]; 
    data2_buf[9] <= data2_buf[10];
    data2_buf[10] <= data2_buf[11]; 
    data2_buf[11] <= data2_buf[12];
    data2 buf[12] <= data2_buf[13]; 
    data2_buf[13] <= IN_DATA_2;
  end
end
else begin
  data2_buf[0] <= data2_buf[1]; 
  data2_buf[1] <= data2_buf[2]; 
  data2_buf[2] <= data2_buf[3]; 
  data2_buf[3] <= data2_buf[4]; 
  data2_buf[4] <= data2_buf[5]; 
  data2_buf[5] <= data2_buf[6]; 
  data2_buf[6] <= data2_buf[7]; 
  data2_buf[7] <= data2_buf[8]; 
  data2_buf[8] <= data2_buf[9]; 
  data2_buf[9] <= data2_buf[10]; 
  data2_buf[10] <= data2_buf[11]; 
  data2_buf[11] <= data2_buf[12]; 
  data2_buf[12] <= data2_buf[13]; 
  data2_buf[13] <= 5'd0;
end
end


always @(posedge CLK or posedge RESET) begin
if (RESET)
  data3_idx <= 5'd0;
else if(IN_VALID == 1'b1) begin 
  if(data3_idx != 5'd21)
    data3 idx <= data3_idx + 5'd1;
  else
    data3_idx <= data3_idx;
end
else
  data3_idx <= data3_idx;
end



always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  data3_buf[0] <= 5'd0;
  data3_buf[1] <= 5'd0; 
  data3_buf[2] <= 5'd0; 
  data3_buf[3] <= 5'd0; 
  data3_buf[4] <= 5'd0; 
  data3_buf[5] <= 5'd0 
  data3_buf[6] <= 5'd0;
  data3_buf[7] <= 5'd0; 
  data3_buf[8] <= 5'd0; 
  data3_buf[9] <= 5'd0; 
  data3_buf[10] <= 5'd0; 
  data3_buf[11] <= 5'd0; 
  data3_buf[12] <= 5'd0; 
  data3_buf[13] <= 5'd0; 
  data3_buf[14] <= 5'd0; 
  data3_buf[15] <= 5'd0; 
  data3_buf[16] <= 5'd0; 
  data3_buf[17] <= 5'd0;
  data3_buf[18] <= 5'd0;
  data3_buf[19] <= 5'd0;
  data3_buf[20] <= 5'd0;
end
else if (KERNEL_VALID || IN_VALID) begin 
  if(data3_idx != 5'd21)
    data3_buf[data3_idx] <= IN_DATA_3;
  else begin
    data3_buf[0] <= data3_buf[1];
    data3_buf[1] <= data3_buf[2];
    data3_buf[2] <= data3_buf[3];
    data3_buf[3] <= data3_buf[4];
    data3_buf[4] <= data3_buf[5]; 
    data3_buf[5] <= data3_buf[6]; 
    data3_buf[6] <= data3_buf[7]; 
    data3_buf[7] <= data3_buf[8]; 
    data3_buf[8] <= data3_buf[9]; 
    data3_buf[9] <= data3_buf[10]; 
    data3_buf[10] <= data3_buf[11]; 
    data3 buf[11] <= data3_buf[12]; 
    data3_buf[12] <= data3_buf[13]; 
    data3_buf[13] <= data3_buf[14]; 
    data3_buf[14] <= data3_buf[15]; 
    data3_buf[15] <= data3_buf[16]; 
    data3_buf[16] <= data3_buf[17]; 
    data3_buf[17] <= data3_buf[18]; 
    data3_buf[18] <= data3_buf[19]; 
    data3_buf[19] <= data3_buf[20]; 
    data3_buf[20] <= IN_DATA_3;
  end
end

else begin
  data3_buf[0] <= data3_buf[1]; 
  data3_buf[1] <= data3_buf[2]; 
  data3_buf[2] <= data3_buf[3]; 
  data3_buf[3] <= data3_buf[4]; 
  data3_buf[4] <= data3_buf[5]; 
  data3_buf[5] <= data3_buf[6]; 
  data3_buf[6] <= data3_buf[7]; 
  data3_buf[7] <= data3_buf[8]; 
  data3_buf[8] <= data3_buf[9]; 
  data3_buf[9] <= data3_buf[10];
  data3_buf[10] <= data3_buf[11];
  data3_buf[11] <= data3_buf[12];
  data3_buf[12] <= data3_buf[13];
  data3_buf[13] <= data3_buf[14];
  data3_buf[14] <= data3_buf[15];
  data3_buf[15] <= data3_buf[16];
  data3_buf[16] <= data3_buf[17];
  data3_buf[17] <= data3_buf[18];
  data3_buf[18] <= data3_buf[19]; 
  data3_buf[19] <= data3_buf[20]; 
  data3_buf[20] <= 5'd0;
end
end


always @(posedge CLK or posedge RESET) begin
if (RESET)
  counter <= 7'd0;
else if (IN_VALID == 1'b1 || current_state == EXPORT) begin 
  if (counter != 7'd127)
    counter <= counter + 7'd1;
  else
    counter<= counter;
end
else
  counter < counter;
end

always @(posedge CLK or posedge RESET) begin
if (RESET)
  kernel_idx1 <= 3'd0;
else if (IN_VALID || current_state== EXPORT) begin 
  if (kernel_idx1 = 3'd6)
    kernel_idx1 <= kernel_idx1 + 3'd1;
  else
    kernel_idx1 <= 3'do;
end
else
  kernel_idx1 <= 3'd0;
end

always @(posedge CLK or posedge RESET) begin
if (RESET) begin
  kernel1[0] <= 8'd0;
  kernel1[1] <= 8'd0;
  kernel1[2] <= 8'd0;
  kernel1[3] <= 8'd0;
  kernel1[4] <= 8'd0;
  kernel1[5] <= 8'd0;
  kernel1[6] <= 8'd0;
end
else if (KERNEL_VALID == 1'b1 && counter <= 7'd6) begin 
  kernell [kernel_idx1] <= KERNEL;
end
else begin
  kernel1[0] <= kernel1[0];
  kernel1[1] <= kernel1[1];
  kernel1[2] <= kernel1[2];
  kernel1[3] <= kernel1[3];
  kernel1[4] <= kernel1[4];
  kernel1[5] <= kernel1[5];
  kernel1[6] <= kernel1[6];
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET)
  convl_chl_idx <= 4'd0;
else if(current_state== MUL_KER || current_state == EXPORT)
  if (counter >= 7'd10 && counter <= 7'd23) 
    conv1_ch1_idx <= conv1_ch1_idx + 4'd1;
  else
    conv1_chl_idx <= conv1_ch1_idx;
end
else
  conv1_ch1_idx <= conv1_ch1_idx;
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch1_mul[0] <= 12'd0; 
  conv1_ch1 mul[1] <= 12'd0;
  conv1_ch1_mul[2] <= 12'd0; 
  conv1_ch1_mul [3] <= 12'd0; 
  conv1_ch1_mul [4] <= 12'd0;
  conv1_ch1_mul [5] <= 12'd0; 
  conv1_ch1_mul [6] <= 12'd0;
end
else if (current_state== MUL_KER || current_state==EXPORT) begin 
  if (counter 7'd7) begin
    conv1_ch1_mul[0] <= kernel1[0] * $signed ({3'd0, datal_buf[0]}); 
    conv1_ch1_mul[1] <= kernel1[1] * $signed ({3'd0, datal_buf[1]}); 
    conv1_ch1 mul[2] <= kernel1[2] * $signed ({3'd0, datal_buf[2]}); 
    conv1_ch1_mul[3] <= kernel1[3] * $signed ({3'd0, datal_buf[3]}); 
    conv1_ch1 mul[4] <= kernel1[4] * $signed ({3'd0, datal_buf[4]}); 
    conv1_ch1_mul[5] <= kernel1[5] * $signed ({3'd0, datal_buf[5]}); 
    conv1_ch1_mul[6] <= kernel1[6] * $signed ({3'd0, datal_buf[6]});
  end
  else begin
    conv1_ch1_mul[0] <= 12'd0; 
    conv1_ch1 mul[1] <= 12'd0;
    conv1_ch1_mul [2] <= 12'd0;
    conv1_ch1_mul [3] <= 12'd0; 
    conv1_ch1_mul [4] <= 12'd0; 
    conv1_ch1 mul[5] <= 12'd0; 
    conv1_ch1_mul [6] <= 12'd0;
  end
end
else begin
  conv1_ch1_mul[0] <= 12'd0;
  conv1_ch1_mul[1] <= 12'd0;
  conv1_ch1_mul[2] <= 12'd0; 
  conv1_ch1_mul[3] <= 12'd0; 
  conv1_ch1_mul[4] <= 12'd0; 
  conv1_ch1_mul[5] <= 12'd0; 
  conv1_ch1_mul[6] <= 12'd0;
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch1_add][0] <= 13'd0; 
  conv1_ch1_add1[1] <= 13'd0;
  conv1_ch1_add1 [2] <= 13'd0;
  conv1_ch1_add1 [3] <= 13'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'08) begin
    conv1_ch1_add1[0] <= conv1_ch1_mul[0] + conv1_ch1_mul[1]; 
    conv1_ch1_add1 [1] <= conv1_ch1_mul [2] + conv1_ch1_mul[3]; 
    conv1_ch1_add1 [2] <= conv1_ch1_mul [4] + conv1_ch1_mul[5]; 
    conv1_ch1_add1[3] <= conv1_ch1_mul[6];
  end
  else begin
    conv1_ch1_add1[0] <= 13'd0;
    conv1_ch1_add1 [1] <= 13'd0;
    conv1_ch1_add1 [2] <= 13'd0;
    conv1_ch1_add1 [3] <= 13'd0;
  end
end
else begin
  conv1_ch1_add1[0] <= 13'd0;
  conv1_ch1_add1 [1] <= 13'd0;
  conv1_ch1_add1 [2] <= 13'd0;
  conv1_ch1_add1 [3] <= 13'd0;
end
end

always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch1_add2[0] <= 14'd0;
  conv1_ch1_add2[1] <= 14'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >=7'd9) begin
    conv1_ch1_add2 [0] <= conv1_ch1_add1 [0] + conv1_ch1_add1[1]; 
    conv1_ch1_add2[1] <= conv1_ch1_add1 [2] + conv1_ch1_add1[3];
  end 
  else begin
    conv1_ch1_add2 [0] <= 14'd0;
    conv1_ch1_add2 [1] <= 14'd0;
  end
end
else begin
  conv1_ch1_add2 [0] <= 14'd0; 
  conv1_ch1_add2 [1] <= 14'd0;
end
end


always @(posedge CLK or posedge RESET) begin 
if(RESET) begin
  conv1_ch1_buf[0] <= 15'd0; 
  conv1_ch1_buf[1] <= 15'd0; 
  conv1 ch1 buf[2] <= 15'd0; 
  conv1_ch1_buf[3] <= 15'd0; 
  conv1_ch1_buf[4] <= 15'd0;
  conv1_ch1_buf[5] <= 15'd0;
  conv1_ch1_buf[6] <= 15'd0;
end
else if (IN_VALID || current_state == UL_KER || current_state == EXPORT) begin
  if (counter 7'd10 && Counter < 7'd17)
    conv1_ch1_buf[conv1_ch1_idx] <= conv1_ch1_add2[0] + conv1_ch1_add2[1];
  else if (counter <= 7'd9) begin
    conv1_ch1_buf[0] <= conv1_ch1_buf[0];
    conv1_ch1_buf[1] <= conv1_ch1_buf[1];
    conv1_ch1_buf[2] <= conv1_ch1_buf[2]; 
    conv1_ch1_buf[3] <= conv1_ch1_buf[3]; 
    conv1_ch1_buf[4] <= conv1_ch1_buf[4]; 
    conv1_ch1_buf[5] <= conv1_ch1_buf[5]; 
    conv1_ch1_buf[6] <= conv1_ch1_buf[6];
  end
else begin
  conv1_ch1_buf[0] <= conv1_ch1_buf[1]; 
  conv1_ch1_buf[1] <= conv1_ch1_buf[2]; 
  conv1_ch1_buf[2] <= conv1_ch1_buf[3]; 
  conv1_ch1_buf[3] <= conv1_ch1_buf[4];
  conv1_ch1_buf[4] <= conv1_ch1_buf[5];
  conv1_ch1_buf[5] <= conv1_ch1_buf[6];
  conv1_ch1_buf[6] <= conv1_ch1_add2[0] + conv1_ch1_add2[1];
end
end
else begin
  conv1_ch1_buf[0] <= conv1_ch1_buf[0];
  conv1_ch1_buf[1] <= conv1_ch1_buf[1];
  conv1_ch1_buf[2] <= conv1_ch1_buf[2];
  conv1_ch1_buf[3] <= conv1_ch1_buf[3]; 
  conv1_ch1_buf[4] <= conv1_ch1_buf[4]; 
  conv1_ch1_buf[5] <= conv1_ch1_buf[5]; 
  conv1_ch1_buf[6] <= conv1_ch1_buf[6];
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET)
  out_ch1_idx <= 4'd0;
else if (current_state== MUL_KER || current_state ==EXPORT) begin
  if (counter >=7'd21 && out_ch1_idx = 4'd14) 
    out_ch1_idx <= out_ch1_idx + 4'd1;
  else
    out_ch1_idx <= out_ch1_idx;
end
else
  out_ch1_idx <= out_ch1_idx;
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch1_mul[0] <= 16'd0; 
  out_ch1_mul[1] <= 16'd0; 
  out_ch1 mul[2] <= 16'd0; 
  out_ch1_mul[3] <= 16'd0;
  out_ch1_mul[4] <= 16'd0;
  out_ch1_mul[5] <= 16'd0;
  out_ch1_mul[6] <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd17) begin
    out_ch1_mul[0] <= kernel1[0] * conv1_ch1_buf[0]; 
    out_ch1_mul[1] <= kernel1[1] * conv1_ch1_buf[1];
    out_ch1_mul[2] <= kernel1[2] * conv1_ch1_buf[2];
    out_ch1_mul[3] <= kernel1[3] * conv1_ch1_buf[3];
    out_ch1_mul[4] <= kernel1[4] * conv1_ch1_buf[4];
    out_ch1_mul[5] <= kernel1[5] * conv1_ch1_buf[5];
    out_ch1_mul[6] <= kernel1[6] * conv1_ch1_buf[6];
  end
  else begin
    out_ch1_mul[0] <= out_ch1_mul[0];
    out_ch1_mul[1] <= out_ch1_mul[1]; 
    out_ch1_mul[2] <= out_ch1_mul[2]; 
    out_ch1_mul[3] <= out_ch1_mul[3]; 
    out_ch1_mul[4] <= out_ch1_mul[4]; 
    out_ch1_mul[5] <= out_ch1_mul[5];
    out_ch1_mul[6] <= out_ch1_mul[6];
  end
end
else begin
  out_ch1_mul[0] <= out_ch1_mul[0];
  out_ch1_mul[1] <= out_ch1_mul[1]; 
  out_ch1_mul[2] <= out_ch1_mul[2]; 
  out_ch1_mul[3] <= out_ch1_mul[3]; 
  out_ch1_mul[4] <= out_ch1_mul[4]; 
  out_ch1 mul[5] <= out_ch1_mul[5]; 
  out_ch1_mul[6] <= out_ch1_mul[6];
end
end


always @(posedge_CLK or posedge RESET) begin 
if (RESET) begin
  out chl add1[0] <= 16'd0; 
  out_ch1_add1[1] <= 16'd0; 
  out_ch1_add1[2] <= 16'd0; 
  out_ch1_add1 [3] <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd18) begin
    out_ch1_add1[0] <= out_ch1_mul[0] + out_ch1_mul[1]; 
    out ch1 add1[1] <= out ch1_mul[2] + out ch1_mul[3]; 
    out_ch1_add1[2] <= out_ch1_mul[4] + out_ch1_mul[5]; 
    out_ch1_add1[3] <= out_ch1_mul[6];
  end 
  else begin
    out_ch1_add1[0] <= out_ch1_add1[0]; 
    out_ch1_add1[1] <= out_ch1_add1[1]; 
    out_ch1_add1[2] <= out_ch1_add1[2]; 
    out_ch1_add1 [3] <= out_ch1_add1 [3];
  end
end
else begin
  out_ch1_add1[0] <= out_ch1_add1[0]; 
  out_ch1_add1[1] <= out_ch1_add1[1];
  out_ch1_add1[2] <= out_ch1_add1[2];
  out_ch1_add1[3] <= out_ch1_add1[3];
end
end

always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch1_add2[0] <= 16'd0;
  out_ch1_add2[1] <= 16'd0;
end
else if (current_state == = MUL_KER || current_state == EXPORT) begin
  if (counter 7'd19) begin
    out_ch1_add2[0] <= out_ch1_add1[0] + out_ch1_add1[1];
    out_ch1_add2[1] <= out_ch1_add1[2] + out_ch1_add1[3];
  end
  else begin
    out_ch1_add2[0] <= out_ch1_add2[0]; 
    out_ch1_add2[1] <= out_ch1_add2[1];
  end
end
else begin
  out_ch1_add2[0] <= out_ch1_add2[0]; 
  out_ch1_add2[1] <= out_ch1_add2[1];
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch1_tmp <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd20)
    out_ch1_tmp <= out_ch1_add2[0] + out_ch1_add2[1];
  else
    out_ch1_tmp <= 16'd0;
end
else
  out_ch1_tmp <= 16'd0;
end


always @(posedge CLK or posedge RESET) begin
if (RESET) begin
  out_ch1_buf[0] <= 16'd0;
  out_ch1_buf[1] <= 16'd0;
  out_ch1_buf[2] <= 16'd0;
  out_ch1_buf[3] <= 16'd0;
  out_ch1_buf[4] <= 16'd0;
  out_ch1_buf[5] <= 16'd0;
  out_ch1_buf[6] <= 16'd0;
  out_ch1_buf[7] <= 16'd0;
  out_ch1_buf[8] <= 16'd0;
  out_ch1_buf[9] <= 16'd0;
  out_ch1_buf[10] <= 16'd0;
  out_ch1_buf[11] <= 16'd0;
  out_ch1_buf[12] <= 16'd0;
  out_ch1_buf[13] <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd21 && counter <= 7'd34) begin 
    if (out_ch1_tmp[15] == 1'b0)
      out_ch1_buf[out_ch1_idx] <= out_ch1_tmp;
    else
      out_ch1_buf[out_ch1_idx] <= 16'd0;
end
else if (counter> 7'd34) begin 
  if (out_ch1_tmp[15] == 1'b0) begin
    out_ch1_buf[0] <= out_ch1_buf[1];
    out_ch1_buf[1] <= out_ch1_buf[2];
    out_ch1_buf[2] <= out_ch1_buf[3]; 
    out_ch1_buf[3] <= out_ch1_buf[4];
    out_ch1_buf[4] <= out_ch1_buf[5];
    out_ch1_buf[5] <= out_ch1_buf[6];
    out_ch1_buf[6] <= out_ch1_buf[7];
    out_ch1_buf[7] <= out_ch1_buf[8]; 
    out_ch1_buf[8] <= out_ch1_buf[9]; 
    out_ch1_buf[9] <= out_ch1_buf[10]; 
    out_ch1_buf[10] <= out_ch1_buf[11]; 
    out_ch1_buf[11] <= out_ch1_buf[12]; 
    out_ch1_buf[12] <= out_ch1_buf[13]; 
    out_ch1_buf[13] <= out_ch1_tmp;
  end
  else begin
    out_ch1_buf[0] <= out_ch1_buf[1];
    out_ch1_buf[1] <= out_ch1_buf[2];
    out_ch1_buf[2] <= out_ch1_buf[3];
    out_ch1_buf[3] <= out_ch1_buf[4];
    out_ch1_buf[4] <= out_ch1_buf[5];
    out_ch1_buf[5] <= out_ch1_buf[6];
    out_ch1_buf[6] <= out_ch1_buf[7];
    out_ch1_buf[7] <= out_ch1_buf[8];
    out_ch1_buf[8] <= out_ch1_buf[9];
    out_ch1_buf[9] <= out_ch1_buf[10]; 
    out_ch1_buf[10] <= out_ch1_buf[11]; 
    out_ch1_buf[11] <= out_ch1_buf[12]; 
    out_ch1_buf[12] <= out_ch1_buf[13];
    out_ch1_buf[13] <= 16'd0;
  end
end
else begin
  out_ch1_buf[0] <= out_ch1_buf[0];
  out_ch1_buf[1] <= out_ch1_buf[1];
  out_ch1_buf[2] <= out_ch1_buf[2];
  out_ch1_buf[3] <= out_ch1_buf[3];
  out_ch1_buf[4] <= out_ch1_buf[4];
  out_ch1_buf[5] <= out_ch1_buf[5];
  out_ch1_buf[6] <= out_ch1_buf[6];
  out_ch1_buf[7] <= out_ch1_buf[7];
  out_ch1_buf[8] <= out_ch1_buf[8];
  out_ch1_buf[9] <= out_ch1_buf[9];
  out_ch1_buf[10] <= out_ch1_buf[10];
  out_ch1_buf[11] <= out_ch1_buf[11];
  out_ch1_buf[12] <= out_ch1_buf[12];
  out_ch1_buf[13] <= out_ch1_buf[13];
end
end 


always @(posedge CLK or posedge RESET) begin 
if (RESET)
  conv1_ch2_idx <= 4'd0;
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd17 && counter <= 7'd23) 
    conv1_ch2_idx <= conv1_ch2_idx + 4'd1;
  else
    conv1_ch2_idx <= conv1_ch2_idx;
end
else
  conv1_ch2_idx <= conv1_ch2_idx;
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch2_mul[0] <= 12'd0;
  conv1_ch2_mul[1] <= 12'd0;
  conv1_ch2_mul[2] <= 12'd0;
  conv1_ch2_mul[3] <= 12'd0;
  conv1_ch2_mul[4] <= 12'd0;
  conv1_ch2_mul[5] <= 12'd0;
  conv1_ch2_mul[6] <= 12'd0;
end
else if (current_state == MUL_KER || current_state ==EXPORT) begin
  if (counter >= 7'd14) begin
    conv1_ch2_mul[0] <= kernel2[0] * $signed ({3'd0, data2_buf[0]}); 
    conv1_ch2_mul[1] <= kernel2[1] * $signed ({3'd0, data2_buf[1]}); 
    conv1_ch2_mul[2] <= kernel2[2] * $signed ({3'd0, data2_buf[2]}); 
    conv1_ch2_mul[3] <= kernel2[3] * $signed ({3'd0, data2_buf[3]}); 
    conv1_ch2_mul[4] <= kernel2[4] * $signed ({3'd0, data2_buf[4]}); 
    conv1_ch2_mul[5] <= kernel2[5] * $signed ({3'd0, data2_buf[5]}); 
    conv1_ch2_mul[6] <= kernel2[6] * $signed ({3'd0, data2_buf[6]});
  end
  else begin
    conv1_ch2_mul[0] <= 12'd0;
    conv1_ch2_mul [1] <= 12'd0;
    conv1_ch2_mul [2] <<= 12'd0;
    conv1_ch2_mul [3] <= 12'd0;
    conv1_ch2_mul [4] <= 12'd0;
    conv1_ch2_mul[5] <= 12'd0;
    conv1_ch2_mul[6] <= 12'd0;
  end
end
else begin
  conv1_ch2_mul[0] <= 12'd0; 
  conv1_ch2_mul[1] <= 12'd0; 
  conv1_ch2_mul[2] <= 12'd0; 
  conv1 ch2 mul[3] <= 12'd0; 
  conv1_ch2_mul[4] <= 12'd0; 
  conv1_ch2_mul[5] <= 12'd0; 
  conv1_ch2_mul[6] <= 12'd0;
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch2_add1[0] <= 13'd0; 
  conv1_ch2_add1[1] <= 13'd0; 
  conv1_ch2_add1[2] <= 13'd0; 
  conv1_ch2_add1[3] <= 13'd0;
end
else if (current_state == MUL_KER || current_state== EXPORT) begin
  if (counter >= 7'd15) begin
    conv1_ch2_add1[0] <= conv1_ch2_mul[0] + conv1_ch2_mul[1]; 
    conv1_ch2_add1[1] <= conv1_ch2_mul[2] + conv1_ch2_mul[3]; 
    conv1_ch2_add1[2] <= conv1_ch2_mul [4] + conv1_ch2_mul[5]; 
    conv1_ch2_add1[3] <= conv1_ch2_mul[6];
  end
  else begin
    conv1_ch2_add1[0] <= 13'd0;
    conv1_ch2_add1[1] <= 13'd0;
    conv1_ch2_add1[2] <= 13'd0;
    conv1_ch2_add1[3] <= 13'd0;
  end
end
else begin
  conv1_ch2_add1[0] <= 13'd0;
  conv1_ch2_add1[1] <= 13'd0;
  conv1_ch2_add1 [2] <= 13'd0;
  conv1_ch2_add1[3] <= 13'd0;
end
end

always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch2_add2[0] <= 14'd0;
  conv1_ch2_add2[1] <= 14'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >=7'd16) begin
    conv1_ch2_add2[0] <= conv1_ch2_add1 [0] + conv1_ch2_add1[1]; 
    conv1_ch2_add2 [1] <= conv1_ch2_add1 [2] + conv1_ch2_add1[3];
  end
  else begin
    conv1_ch2_add2 [0] <= 14'd0;
    conv1_ch2_add2[1] <= 14'd0;
  end
end
else begin
  conv1_ch2_add2[0] <= 14'd0; 
  conv1_ch2_add2[1] <= 14'd0;
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch2_buf[0] <= 15'd0;
  conv1_ch2_buf[1] <= 15'd0;
  conv1_ch2_buf[2] <= 15'd0;
  conv1_ch2_buf[3] <= 15'd0;
  conv1_ch2_buf[4] <= 15'd0;
  conv1_ch2_buf[5] <= 15'd0;
  conv1_ch2_buf[6] <= 15'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd17 && counter <= 7'd23)
    conv1_ch2_buf[conv1_ch2_idx] <= conv1_ch2_add2[0] + conv1_ch2_add2[1];
  else if (counter > 7'd23) begin
   conv1_ch2_buf[0] <= conv1_ch2_buf[1];
   conv1_ch2_buf[1] <= conv1_ch2_buf[2];
   conv1_ch2_buf[2] <= conv1_ch2_buf[3];
   conv1_ch2_buf[3] <= conv1_ch2_buf[4];
   conv1_ch2_buf[4] <= conv1_ch2_buf[5];
   conv1_ch2_buf[5] <= conv1_ch2_buf[6];
   conv1_ch2_buf[6] <= conv1_ch2_add2[0] + conv1_ch2_add2[1];
  end
  else begin
    conv1_ch2_buf[0] <= conv1_ch2_buf[0];
    conv1_ch2_buf[1] <= conv1_ch2_buf[1];
    conv1_ch2_buf[2] <= conv1_ch2_buf[2]; 
    conv1_ch2_buf[3] <= conv1_ch2_buf[3]; 
    conv1_ch2_buf[4] <= conv1_ch2_buf[4];
    conv1_ch2_buf[5] <= conv1_ch2_buf[5]; 
    conv1_ch2_buf[6] <= conv1_ch2_buf[6];
  end
end
else begin
  conv1_ch2_buf[0] <= conv1_ch2_buf[0]; 
  conv1_ch2_buf[1] <= conv1_ch2_buf[1]; 
  conv1_ch2_buf[2] <= conv1_ch2_buf[2]; 
  conv1_ch2_buf[3] <= conv1_ch2_buf[3]; 
  conv1_ch2_buf[4] <= conv1_ch2_buf[4]; 
  conv1 ch2 buf[5] <= conv1 ch2 buf[5]; 
  conv1_ch2_buf[6] <= conv1_ch2_buf[6];
end
end


always @(posedge CLK or posedge RESET) begin
if (RESET)
  out ch2 idx <= 4'd0;
else if (current_state == MUL_KER || current_state == EXPORT) begin
  if (counter >=7'd28 && out_ch2_idx != 4'd6) 
    out_ch2_idx <= out_ch2_idx + 4'd1;
  else
    out_ch2_idx <= out_ch2_idx;
end
else
  out_ch2_idx <= out_ch2_idx;
end

always @(posedge CLK or posedge RESET) begin
if (RESET) begin
  out_ch2_mul[0] <= 16'd0;
  out_ch2_mul[1] <= 16'd0;
  out_ch2_mul[2] <= 16'd0;
  out_ch2_mul[3] <= 16'd0;
  out_ch2_mul[4] <= 16'd0;
  out_ch2_mul[5] <= 16'd0;
  out_ch2_mul[6] <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd24) begin
    out_ch2_mul[0] <= kernel2[0] * conv1_ch2_buf[0];
    out_ch2_mul[1] <= kernel2[1] * conv1_ch2_buf[1];
    out_ch2_mul[2] <= kernel2[2] * conv1_ch2_buf[2];
    out_ch2_mul[3] <= kernel2[3] * conv1_ch2_buf[3];
    out_ch2_mul[4] <= kernel2[4] * conv1_ch2_buf[4];
    out_ch2_mul[5] <= kernel2[5] * conv1_ch2_buf[5];
    out_ch2_mul[6] <= kernel2[6] * conv1_ch2_buf[6];
  end
  else begin
   out_ch2_mul[0] <= out_ch2_mul[0]; 
   out_ch2_mul[1] <= out_ch2_mul[1];
   out_ch2_mul[2] <= out_ch2_mul[2];
   out_ch2_mul[3] <= out_ch2_mul[3]; 
   out_ch2_mul[4] <= out_ch2_mul[4];
   out_ch2_mul[5] <= out_ch2_mul[5]; 
   out_ch2_mul[6] <= out_ch2_mul[6];
  end
end
else begin
  out_ch2_mul[0] <= out_ch2_mul[0];
  out_ch2_mul[1] <= out_ch2_mul[1];
  out_ch2_mul[2] <= out_ch2_mul[2]; 
  out_ch2_mul[3] <= out_ch2_mul[3];
  out_ch2_mul[4] <= out_ch2_mul[4]; 
  out_ch2_mul[5] <= out_ch2_mul[5]; 
  out_ch2_mul[6] <= out_ch2_mul[6];
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch2_add1[0] <= 16'd0;
  out_ch2_add1[1] <= 16'd0;
  out_ch2_add1[2] <= 16'd0;
  out_ch2_add1[3] <= 16'd0;
end
else if (current_state == MUL_KER || current_state== EXPORT) begin
  if (counter >= 7'd25) begin
    out_ch2_add1[0] <= out_ch2_mul[0] + out_ch2_mul[1]; 
    out_ch2_add1[1] <= out_ch2_mul [2] + out_ch2_mul[3]; 
    out_ch2_add1[2] <= out_ch2_mul [4] + out_ch2_mul[5]; 
    out_ch2_add1[3] <= out_ch2_mul[6];
  end
  else begin
    out_ch2_add1[0] <= out_ch2_add1[0]; 
    out_ch2_add1[1] <= out_ch2_add1[1]; 
    out_ch2_add1[2] <= out_ch2_add1[2]; 
    out_ch2_add1[3] <= out_ch2_add1[3];
  end
end
else begin
  out_ch2_add1[0] <= out_ch2_add1[0]; 
  out_ch2_add1[1] <= out_ch2_add1[1]; 
  out_ch2_add1[2] <= out_ch2_add1[2]; 
  out_ch2_add1[3] <= out_ch2_add1[3];
end
end

always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch2_add2[0] <= 16'd0; 
  out_ch2_add2[1] <= 16'd0;
end
else if (current_state== MUL_KER || current_state== = EXPORT) begin
  if(counter 7'd26) begin
    out_ch2_add2[0] <= out_ch2_add1 [0] + out_ch2_add1[1]; 
    out_ch2_add2[1] <= out_ch2_add1 [2] + out_ch2_add1[3];
  end 
  else begin
    out_ch2_add2[0] <= out_ch2_add2[0]; 
    out_ch2_add2[1] <= out_ch2_add2[1];
end
else begin
  out_ch2_add2[0] <= out_ch2_add2[0];
  out_ch2_add2[1] <= out_ch2_add2[1];
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
out_ch2_tmp <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd27)
    out_ch2_tmp <= out_ch2_add2[0] + out_ch2_add2[1];
  else
    out_ch2_tmp <= 16'd0;
end
else
  out_ch2_tmp <= 16'd0;
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch2_buf[0] <= 16'd0;
  out_ch2_buf[1] <= 16'd0;
  out_ch2_buf[2] <= 16'd0;
  out_ch2_buf[3] <= 16'd0;
  out_ch2_buf[4] <= 16'd0;
  out_ch2_buf[5] <= 16'd0;
  out_ch2_buf[6] <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter >= 7'd28 && counter <= 7'd34) begin 
    if (out_ch2_tmp[15] == 1'b0)
      out_ch2_buf[out_ch2_idx] <= out_ch2_tmp;
    else
      out_ch2_buf[out_ch2_idx] <= 16'd0;
  else if (counter > 7'd34) begin 
    if (out_ch2_tmp[15] == 1'b0) begin
      out_ch2_buf[0] <= out_ch2_buf[1]; 
      out_ch2_buf[1] <= out_ch2_buf[2]; 
      out_ch2_buf[2] <= out_ch2_buf[3]; 
      out_ch2_buf[3] <= out_ch2_buf[4];
      out_ch2_buf[4] <= out_ch2_buf[5];
      out_ch2_buf[5] <= out_ch2_buf[6]; 
      out_ch2_buf[6] <= out_ch2_tmp;
    end
    else begin
      out_ch2_buf[0] <= out_ch2_buf[1];
      out_ch2_buf[1] <= out_ch2_buf[2];
      out_ch2_buf[2] <= out_ch2_buf[3]; 
      out_ch2_buf[3] <= out_ch2_buf[4]; 
      out_ch2_buf[4] <= out_ch2_buf[5]; 
      out_ch2_buf[5] <= out_ch2_buf[6]; 
      out_ch2_buf[6] <= 16'd0;
    end
  end
  else begin
    out_ch2_buf[0] <= out_ch2_buf[0];
    out_ch2_buf[1] <= out_ch2_buf[1];
    out_ch2_buf[2] <= out_ch2_buf[2];
    out_ch2_buf[3] <= out_ch2_buf[3]; 
    out_ch2_buf[4] <= out_ch2_buf[4]; 
    out_ch2_buf[5] <= out_ch2_buf[5]; 
    out_ch2_buf[6] <= out_ch2_buf[6];
  end
end
end


always @(posedge CLK or posedge RESET) begin
if (RESET) begin
  kernel2[0] <= 8'd0;
  kernel2[1] <= 8'd0;
  kernel2[2] <= 8'd0;
  kernel2[3] <= 8'd0;
  kernel2[4] <= 8'd0;
  kernel2[5] <= 8'd0;
  kernel2[6] <= 8'd0;
end
else if (KERNEL_VALID == 1'b1 && counter >= 7'd7 && counter << 7'd13) begin
  kernel2 [kernel_idx1] <= KERNEL;
end
else begin
  kernel2[0] <= kernel2[0];
  kernel2[1] <= kernel2[1];
  kernel2[2] <= kernel2[2]; 
  kernel2[3] <= kernel2[3]; 
  kernel2[4] <= kernel2[4];
  kernel2[5] <= kernel2[5];
  kernel2[6] <= kernel2[6];
end
end

always @(posedge CLK or posedge RESET) begin
if (RESET) begin
  kernel3[0] <= 8'd0;
  kernel3[1] <= 8'd0;
  kernel3[2] <= 8'd0;
  kernel3[3] <= 8'd0;
  kernel3[4] <= 8'd0;
  kernel3[5] <= 8'd0;
  kernel3[6] <= 8'd0;
end
else if (KERNEL_VALID == 1'b1 && counter >= 7'd14 && counter <= 7'd20) begin
  kernel3 [kernel_idx1] <= KERNEL;
end
else begin
  kernel3[0] <= kernel3[0];
  kernel3[1] <= kernel3[1];
  kernel3[2] <= kernel3[2];
  kernel3[3] <= kernel3[3]; 
  kernel3[4] <= kernel3[4];
  kernel3[5] <= kernel3[5]; 
  kernel3[6] <= kernel3[6];
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET)
  conv1_ch3_idx <= 4'd0;
else if (current_state== MUL_KER ||current_state == EXPORT) begin
  if (counter >= 7'd24 && counter <= 7'd30) 
    conv1_ch3_idx <= conv1_ch3_idx + 4'd1;
  else
    conv1_ch3_idx <= conv1_ch3_idx;
end
else
  conv1_ch3_idx <= conv1_ch3_idx;
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch3_mul[0] <= 12'd0; 
  conv1_ch3_mul[1] <= 12'd0; 
  conv1 ch3 mul[2] <= 12'd0; 
  conv1_ch3_mul[3] <= 12'd0; 
  conv1_ch3_mul[4] <= 12'd0; 
  conv1_ch3_mul [5] <= 12'd0; 
  conv1_ch3_mul[6] <= 12'd0;
end
else if (current_state== MUL_KER || current_state==EXPORT) begin
  if (counter >= 7'd21) begin
    conv1_ch3_mul[0] <= kernel3[0] * $signed ({3'd0, data3_buf[0]}); 
    conv1_ch3_mul[1] <= kernel3[1] * $signed ({3'd0, data3_buf[1]}); 
    conv1_ch3_mul[2] <= kernel3[2] * $signed ({3'd0, data3_buf[2]}); 
    conv1_ch3_mul[3] << kernel3[3] * $signed ({3'd0, data3_buf[3]}); 
    conv1_ch3 mul[4] <= kernel3[4] * $signed ({3'd0, data3_buf[4]}); 
    conv1_ch3_mul[5] <= kernel3[5] * $signed ({3'd0, data3_buf[5]}); 
    conv1_ch3_mul[6] <= kernel3[6] * $signed ({3'd0, data3_buf[6}); 
  end
  else begin
    conv1_ch3_mul[0] <= 12'd0; 
    conv1_ch3_mul[1] <= 12'd0; 
    conv1_ch3_mul [2] <= 12'd0; 
    conv1_ch3_mul[3] <= 12'd0; 
    conv1 ch3 mul[4] <= 12'd0; 
    conv1_ch3_mul[5] <= 12'd0; 
    conv1_ch3_mul[6] <= 12'd0;
  end
end
else begin
  conv1_ch3_mul[0] <= 12'd0;
  conv1_ch3_mul[1] <= 12'd0;
  conv1_ch3_mul[2] <= 12'd0;
  conv1_ch3_mul[3] <= 12'd0; 
  conv1_ch3_mul[4] <= 12'd0;
  conv1_ch3_mul[5] <= 12'd0; 
  conv1_ch3_mul[6] <= 12'd0;
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch3_add1[0] <= 13'd0; 
  conv1_ch3_add1[1] <= 13'd0; 
  conv1_ch3_add1[2] <= 13'd0; 
  conv1_ch3_add1[3] <= 13'd0;
end
else if (current_state== MUL_KER || current_state ==EXPORT) begin
  if (counter 7'd21) begin
    conv1_ch3_add1[0] <= conv1_ch3_mul[0] + conv1_ch3_mul[1]; 
    conv1_ch3_add1[1] <= conv1_ch3_mul[2] + conv1_ch3_mul[3]; 
    conv1_ch3_add1[2] <= conv1_ch3_mul[4] + conv1_ch3_mul[5]; 
    conv1_ch3_add1[3] <= conv1_ch3_mul[6];
  end
  else begin
    conv1_ch3_add1[0] <= 13'd0;
    conv1_ch3_add1[1] <= 13'd0;
    conv1_ch3_add1[2] <= 13'd0;
    conv1_ch3_add1[3] <= 13'd0;
  end
end
else begin
  conv1_ch3_add1[0] <= 13'd0; 
  conv1_ch3_add1[1] <= 13'd0;
  conv1_ch3_add1[2] <= 13'd0;
  conv1_ch3_add1[3] <= 13'd0;
end
end

always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch3_add2 [0] <= 14'd0;
  conv1_ch3_add2[1] <= 14'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if(counter 7'd22) begin
    conv1_ch3_add2 [0] <= conv1_ch3_add1[0] + conv1_ch3_add1[1]; 
    conv1_ch3_add2[1] <= conv1_ch3_add1[2] + conv1_ch3_add1[3];
  end
  else begin
    conv1_ch3_add2[0] <= 14'd0;
    conv1_ch3_add2[1] <= 14'd0;
  end
end
else begin
  conv1_ch3_add2[0] <= 14'd0; conv1_ch3_add2[1] <= 14'd0;
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  conv1_ch3_buf[0] <= 15'd0;
  conv1_ch3_buf[1] <= 15'd0;
  conv1_ch3_buf[2] <= 15'd0;
  conv1_ch3_buf[3] <= 15'd0;
  conv1_ch3_buf[4] <= 15'd0;
  conv1_ch3_buf[5] <= 15'd0;
  conv1_ch3_buf[6] <= 15'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if(counter 7'd23 && counter <= 7'd30)
    conv1_ch3_buf[conv1_ch3_idx] <= conv1_ch3_add2 [0] + conv1_ch3_add2[1];
  else if (counter > 7'd30) begin
    conv1_ch3_buf[0] <= conv1_ch3_buf[1];
    conv1_ch3_buf[1] <= conv1_ch3_buf[2];
    conv1_ch3_buf[2] <= conv1_ch3_buf[3];
    conv1_ch3_buf[3] <= conv1_ch3_buf[4];
    conv1_ch3_buf[4] <= conv1_ch3_buf[5];
    conv1_ch3_buf[5] <= conv1_ch3_buf[6];
    conv1_ch3_buf[6] <= conv1_ch3_add2[0] + conv1_ch3_add2[1]; 
  end
  else begin
    conv1_ch3_buf[0] <= conv1_ch3_buf[0];
    conv1_ch3_buf[1] <= conv1_ch3_buf[1];
    conv1_ch3_buf[2] <= conv1_ch3_buf[2]; 
    conv1_ch3_buf[3] <= conv1_ch3_buf[3]; 
    conv1_ch3_buf[4] <= conv1_ch3_buf[4];
    conv1_ch3_buf[5] <= conv1_ch3_buf[5]; 
    conv1_ch3_buf[6] <= conv1_ch3_buf[6];
  end
end
else begin
  conv1_ch3_buf[0] <= conv1_ch3_buf[0]; 
  conv1_ch3_buf[1] <= conv1_ch3_buf[1]; 
  conv1_ch3_buf[2] <= conv1_ch3_buf[2]; 
  conv1_ch3_buf[3] <= conv1_ch3_buf[3]; 
  conv1_ch3_buf[4] <= conv1_ch3_buf[4]; 
  conv1_ch3_buf[5] <= conv1_ch3_buf[5]; 
  conv1_ch3_buf[6] <= conv1_ch3_buf[6];
end
end


always @(posedge CLK or posedge RESET) begin
if (RESET) begin
  out_ch3_mul[0] <= 16'd0; 
  out_ch3 mul[1] <= 16'd0; 
  out_ch3_mul[2] <= 16'd0; 
  out_ch3_mul[3] <= 16'd0; 
  out_ch3_mul[4] <= 16'd0;
  out_ch3_mul[5] <= 16'd0;
  out_ch3_mul[6] <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if (counter 7'd31) begin
    out_ch3_mul[0] <= kernel3[0] * conv1_ch3_buf[0];
    out_ch3_mul[1] <= kernel3[1] * conv1_ch3_buf[1];
    out_ch3_mul[2] <= kernel3[2] * conv1_ch3_buf[2];
    out_ch3_mul[3] <= kernel3[3] * conv1_ch3_buf[3];
    out_ch3_mul[4] <= kernel3[4] * conv1_ch3_buf[4];
    out_ch3_mul[5] <= kernel3[5] * conv1_ch3_buf[5];
    out_ch3_mul[6] <= kernel3[6] * conv1_ch3_buf[6];
  end
  else begin
    out_ch3_mul[0] <= out_ch3_mul[0];
    out_ch3_mul[1] <= out_ch3_mul[1];
    out_ch3_mul[2] <= out_ch3_mul[2];
    out_ch3_mul[3] <= out_ch3_mul[3];
    out_ch3_mul[4] <= out_ch3_mul[4];
    out_ch3_mul[5] <= out_ch3_mul[5];
    out_ch3_mul[6] <= out_ch3_mul[6];
  end
end
else begin
  out_ch3_mul[0] <= out_ch3_mul[0]; 
  out_ch3_mul[1] <= out_ch3_mul[1]; 
  out_ch3_mul[2] <= out_ch3_mul[2]; 
  out_ch3_mul[3] <= out_ch3_mul[3]; 
  out_ch3_mul[4] <= out_ch3_mul[4]; 
  out ch3_mul[5] <= out ch3 mul[5]; 
  out_ch3_mul[6] <= out_ch3_mul[6];
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch3_add1[0] <= 16'd0;
  out_ch3_add1[1] <= 16'd0;
  out_ch3_add1[2] <= 16'd0;
  out_ch3_add1[3] <= 16'd0;
end
else if (current_state == MUL_KER || current_state== EXPORT) begin
  if (counter >= 7'd32) begin
    out_ch3_add1[0] <= out_ch3_mul[0] + out_ch3_mul[1]; 
    out_ch3_add1[1] <= out_ch3_mul [2] + out_ch3_mul[3]; 
    out_ch3_add1[2] <= out_ch3_mul [4] + out_ch3_mul[5]; 
    out_ch3_add1[3] <= out_ch3_mul[6];
  end
  else begin
    out_ch3_add1[0] <= out_ch3_add1[0];
    out_ch3_add1[1] <= out_ch3_add1[1];
    out_ch3_add1[2] <= out_ch3_add1[2]; 
    out_ch3_add1[3] <= out_ch3_add1[3];
  end
end
else begin
  out_ch3_add1[0] <= out_ch3_add1[0]; 
  out_ch3_add1[1] <= out_ch3_add1[1]; 
  out_ch3_add1[2] <= out_ch3_add1[2]; 
  out_ch3_add1[3] <= out_ch3_add1[3];
end
end

always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch3_add2[0] <= 16'd0;
  out_ch3_add2[1] <= 16'd0;
end
else if (current_state== MUL_KER || current_state == EXPORT) begin
  if(counter >= 7'd33) begin
    out_ch3_add2[0] <= out_ch3_add1 [0] + out_ch3_add1[1]; 
    out_ch3_add2[1] <= out_ch3_add1 [2] + out_ch3_add1[3];
  end 
  else begin
    out_ch3_add2[0] <= out_ch3_add2[0]; 
    out_ch3_add2[1] <= out_ch3_add2[1];
  end
end
else begin
  out_ch3_add2[0] <= out_ch3_add2[0]; 
  out_ch3_add2[1] <= out_ch3_add2[1];
end
end


always @(posedge CLK or posedge RESET) begin 
if (RESET) begin
  out_ch3_tmp <= 16'd0;
end
else if (counter >= 7'd34) begin
  out_ch3_tmp <= out_ch3_add2[0] + out_ch3_add2[1];
end
else
  out_ch3_tmp <= 16'd0;
end


always @(posedge CLK or posedge RESET) begin
if (RESET)
  point_wisel_tmp <= 32'd0;
else if (counter >= 7'd35) begin
  point_wisel_tmp <= $signed (out_ch1_buf[0]) * point_wisel;
end
else
  point_wisel_tmp <= 32'd0;
end

always @(posedge CLK or posedge RESET) begin
if (RESET)
  point_wise2_tmp <= 32'd0;
else if (counter >= 7'd35) begin
  point_wise2_tmp <= $signed (out_ch2_buf[0]) * point_wise2;
end
else
  point_wise2_tmp <= 32'd0;
end

always @(posedge CLK or posedge RESET) begin
if (RESET)
  point_wise3_tmp <= 32'd0;
else if (counter >= 7'd35) begin
  if (out_ch3_tmp[15] == 1'b0)
    point_wise3_tmp <= out_ch3_tmp * point_wise3;
  else
    point_wise3_tmp <= 32'd0;
  end
else
  point_wise3_tmp <= 32'd0;
end


always @(posedge CLK or posedge RESET) begin
if (RESET)
  point_wise_sum <= 32'd0;
else if (next_state == EXPORT || current_state == EXPORT) begin
  point_wise_sum <= point_wisel_tmp + point_wise2_tmp + point_wise3_tmp;
end
else
  point_wise_sum <= 32'd0;
end

always @(posedge CLK or posedge RESET) begin
if (RESET)
  OUT DATA <= 32'd0;
else if (current_state== EXPORT) begin
  if (point_wise_sum [31] == 1'b0)
    OUT_DATA=point_wise_sum;
  else
    OUT_DATA <= 32'd0;
end
else
  OUT_DATA <= 32'd0;
end

endmodule
