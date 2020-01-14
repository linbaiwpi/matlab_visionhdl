kernel = [1  4  7  4 1;
          4 16 26 16 4;
          7 26 41 26 7;
          4 16 26 16 4;
          1  4  7  4 1;]/273;

Gx_kernel=[-1 0 1;
           -2 0 2; 
           -1 0 1];
Gy_kernel=[1  2  1;
           0  0  0; 
          -1 -2 -1];
      
totalPixels = 320*402;

minVal = 80;
maxVal = 100;