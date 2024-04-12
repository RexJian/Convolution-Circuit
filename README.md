# Convolution Circuit
In the lab, I am working on designing a circuit that conducts a sequence of convolution operations on an input image, followed by applying the ReLU activation function. More specifically, I have implemented depth-wise convolutions and point-wise convolutions. Besides, the timing constraint for the clock period must be <strong> 0.37ns </strong> in logic synthesis and the latency of my design is <strong> less than 15 cycles </strong>. 

## Architecture
The input image has dimensions of 1x100x3, representing height, width, and the number of channels, respectively. The processing involves two rounds of depth-wise convolution, utilizing a set of three 1x7 filters for each channel of the image. The ReLU activation function is applied once, after both rounds of depth-wise convolution are completed. The architecture is like the image below.
<p align="center">
  <img src="https://github.com/RexJian/Convolution-Circuit/blob/main/Architecture.png" width="1000" height="550">
</p>

## Specification

| Signal Name | I/O | Width | Sample Description |
| :----: | :----: | :----: | :----|
| CLK | I | 1 | Clock Signal |
| RST | I | 1 | Asynchronous reset signal |
| IN_VALID | I | 1 | Asserted when IN_DATA is valid|
| IN_DATA_1 | I | 5 | Input pixel values of channel one(unsigned) |
| IN_DATA_2 | I | 5 | Input pixel values of channel two(unsigned) |
| IN_DATA_3 | I | 5 | Input pixel values of channel three(unsigned) |
| KERNEL_VALID | I | 1 | Asserted when KERNEL is valid|
| KERNEL | I | 8 | Input filter kernels, include three 1x7 depth-wise filter kernel and three point-wise filter kernels consecutively(both signed numbers)|
| OUT_VALID | O | 1 | Asserted when OUT_DATA is valid |
| OUT_DATA | O | 32 | The final output image (unsigned number) |

## Simulate Waveform
<strong> Step1: </strong>  
When the IN_VALID and KERNEL_VALID signals are asserted, I record the channel's data and its corresponding kernel.
<p align="left">
  <img src="https://github.com/RexJian/Convolution-Circuit/blob/main/Wave/wave1.png" width="1000" height="200" alt="wave">
</p> 

<strong> Step2: </strong>  
  
After the channel's data has been completely loaded, I will calculate the convolution and apply the ReLU function. Once all channels have been fully calculated, the OUT_VALID signal will be asserted, and the results of the series of convolutions will be exported.
<p align="left">
  <img src="https://github.com/RexJian/Convolution-Circuit/blob/main/Wave/wave2.png" width="1600" height="220" alt="wave">
</p> 

<strong> Step3: </strong>  
Once all pixel convolution results have been exported, the OUT_VALID signal wil become zero. 
<p align="left">
  <img src="https://github.com/RexJian/Convolution-Circuit/blob/main/Wave/wave3.png" width="1400" height="220" alt="wave">
</p> 
