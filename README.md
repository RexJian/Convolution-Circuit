# Convolution Circuit
In the lab, I am working on designing a circuit that conducts a sequence of convolution operations on an input image, followed by applying the RELU activation function. More specifically, I have implemented depth-wise convolutions and point-wise convolutions.

## Architecture
The input image has dimensions of 1x100x3, representing height, width, and the number of channels, respectively. The processing involves two rounds of depth-wise convolution, utilizing a set of three 1x7 filters for each channel of the image. The ReLU activation function is applied once, after both rounds of depth-wise convolution are completed. The architecture is like the image below.
