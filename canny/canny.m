img = imread('rhions.png');
img = im2double(img);

kernel1 = [1  4  7  4 1;
          4 16 26 16 4;
          7 26 41 26 7;
          4 16 26 16 4;
          1  4  7  4 1;]/273;
      
kernel2 = [2  4  5  4 2;
           4  9 12  9 4;
           5 12 15 12 5;
           4  9 12  9 4;
           2  4  5  4 2]/115;
%img = imfilter(img, kernel2, 'symmetric', 'conv');
img_gaussian = conv2(img, rot90(kernel1,2),'same');
%img_gaussian_ref = img_gaussian(3:242,3:322);
%imshow(img_gaussian),title('image after gaussian filter');

%% sobel
Gx_kernel = fspecial('sobel');
Gy_kernel = Gx_kernel';
Gx_kernel=[-1 0 1;
           -2 0 2; 
           -1 0 1];
Gy_kernel=[1  2  1;
           0  0  0; 
          -1 -2 -1];
Gx = conv2(img_gaussian,rot90(Gx_kernel,2),'same');
Gy = conv2(img_gaussian,rot90(Gy_kernel,2),'same');
img_sobel = abs(Gx)+abs(Gy);
figure;
imshow(img_sobel),title('image after sobel filter');


[M,N] = size(img_sobel);
img_theta = zeros(M,N);
img_theta1 = zeros(M,N);
img_theta2 = zeros(M,N);
img_theta3 = zeros(M,N);
temp_array = zeros(M,N);
for i = 1:M
    for j = 1:N
        temp = atan2(Gy(i,j),Gx(i,j));
        temp_array(i,j) = temp;
        if temp<-pi/2
            img_theta(i,j) = temp+pi;
        elseif temp>pi/2
            img_theta(i,j) = temp-pi;
        else
            img_theta(i,j) = temp;
        end
    end
end
img_theta1 = img_theta*180/pi;
for i = 1:M
    for j = 1:N
        if img_theta1(i,j)<0
            img_theta2(i,j) = img_theta1(i,j)-90;
            img_theta2(i,j) = abs(img_theta2(i,j));
        else
            img_theta2(i,j) = img_theta1(i,j);
        end
    end
end

alt_img_theta2 = zeros(M,N);
for i = 1:M
    for j = 1:N
        if img_theta(i,j)<0
            alt_img_theta2(i,j) = img_theta(i,j)-pi/2;
            alt_img_theta2(i,j) = abs(alt_img_theta2(i,j));
        else
            alt_img_theta2(i,j) = img_theta(i,j);
        end
    end
end
alt_img_theta2 = alt_img_theta2*180/pi;
            
for i=1:M
    for j=1:N
        if ((0<img_theta2(i,j))&&(img_theta2(i,j)<22.5))||((157.5<img_theta2(i,j))&&(img_theta2(i,j)<181))
            img_theta3(i,j)=0;
        elseif (22.5<img_theta2(i,j))&&(img_theta2(i,j)<67.5)
            img_theta3(i,j)=45;
        elseif (67.5<img_theta2(i,j))&&(img_theta2(i,j)<112.5)  
            img_theta3(i,j)=90;
        elseif (112.5<img_theta2(i,j))&&(img_theta2(i,j)<157.5)
            img_theta3(i,j)=135;
        end
    end
end 
% since in nms we need this angle as index, in hardware we could divide the
% angle by 22.5, then we get the index esily

%% non-maxima suppression
[M,N] = size(img_sobel);
img_sobel_pad = zeros(M+2,N+2);
img_sobel_pad(2:M+1,2:N+1) = img_sobel;
img_nms = zeros(M,N);
for i = 2:M+1
    for j = 2:N+1
        patch = img_sobel_pad(i-1:i+1,j-1:j+1);
        theta = img_theta3(i-1,j-1);
        % patch
        % 1 4 7 
        % 2 5 8
        % 3 6 9
        
        switch theta
            case 90
                if ((patch(5) > patch(4)) && (patch(5) > patch(6)))
                    img_nms(i-1,j-1) = patch(5);
                end
            case 45
                if ((patch(5) > patch(3)) && (patch(5) > patch(7)))
                    img_nms(i-1,j-1) = patch(5);
                end
            case 0
                if ((patch(5) > patch(2)) && (patch(5) > patch(8)))
                    img_nms(i-1,j-1) = patch(5);
                end
            case 135
                if ((patch(5) > patch(1)) && (patch(5) > patch(9)))
                    img_nms(i-1,j-1) = patch(5);
                end
        end
    end
end
img_nms=im2uint8(img_nms);
figure;
imshow(img_nms),title('image after nms');
%% double threshold
[M,N] = size(img_nms);
img_dth = zeros(M,N,'logical');
minVal = 80;
maxVal = 100;

for i = 1:M-2
    for j = 1:N-2
        if img_nms(i,j) > maxVal
            img_dth(i,j) = true;
        elseif img_nms(i,j) > minVal
            patch = (img_nms(i:i+2,j:j+2)>maxVal);
            patch2 = img_dth(i:i+2,j:j+2);
            if sum(sum(patch))>0 ||  sum(sum(patch2))>0
                img_dth(i,j) = true;
            end
        end
    end
end
figure;
imshow(img_dth);