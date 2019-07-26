% v = VideoReader('rhinos.avi');
% img = rgb2gray(readFrame(v));

img = imread('test_1080p.bmp');
[M,N,~] = size(img);

img_gray = zeros(M,N);
for i = 1:M
    for j = 1:N
        gray_val =  (66 * double(img(i,j,1)) + ...
                    129 * double(img(i,j,2)) + ...
                     25 * double(img(i,j,3)) + ...
                    128);
        img_gray(i,j) = bitshift(gray_val, -8) + 16;
    end
end
img = uint8(img_gray);

%imshow(uint8(img_gray))

%img = rgb2gray(img);



% sobel kernel
Gx = [-1 0 1;
      -2 0 2
      -1 0 1];
Gy = [ 1  2  1;
       0  0  0
      -1 -2 -1];

% padding - symmetric
img_pad = zeros(M+2,N+2);
img_pad(2:M+1,2:N+1) = img;
img_pad(1,:) = img_pad(2,:);
img_pad(M+2,:) = img_pad(M+1,:);
img_pad(:,1) = img_pad(:,2);
img_pad(:,N+2) = img_pad(:,N+1);

% filter
img_sobel = zeros(M,N,'uint8');
img_sobel_test = zeros(M,N,'uint8');
for i = 2:M+1
    for j = 2:N+1
        patch = img_pad(i-1:i+1,j-1:j+1);
        img_Gx = sum(sum(patch.*Gx));
        img_Gy = sum(sum(patch.*Gy));
        img_sobel(i-1,j-1) = abs(img_Gx) + abs(img_Gy);
        
        if i == 438+1 && j == 9+1
            disp();
        end
        
        edge_val = 255-uint8(img_sobel(i-1,j-1));
        if (edge_val > 200)
            edge_val = 255;
        elseif (edge_val < 100)
            edge_val = 0;
        end
        img_sobel_test(i-1,j-1) = edge_val;
    end
end

img_sobel_test_rgb = zeros(M,N,3,'uint8');
img_sobel_test_rgb(:,:,1) = img_sobel_test;
img_sobel_test_rgb(:,:,2) = img_sobel_test;
img_sobel_test_rgb(:,:,3) = img_sobel_test;
imshow(img_sobel_test_rgb)

img_sobel_test_r = img_sobel_test;
img_xilinx = imread('result_1080p_golden.bmp');
img_xilinx_r = img_xilinx(:,:,1);
