img = imread('img_test.png');

if size(img,3) == 3
    img = rgb2gray(img);
end

% reference
IntegralImage_ref = integralImage(img);

% DUT
img_double = im2double(img)*255;

[M, N] = size(img);
lineTemp = zeros(1,N);
IntegralImage_dut = zeros(M,N);
pixelAccum_DBG = zeros(M,N);

for i = 1:M
    pixelAccum = 0;
    for j = 1:N
        pixelAccum = img_double(i,j) + pixelAccum;
        lineTemp(j) = pixelAccum + lineTemp(j);
        pixelAccum_DBG(i,j) = pixelAccum;
    end
    if i ==4
        disp(' ');
    end
    IntegralImage_dut(i,:) = lineTemp;
end

if sum(sum(IntegralImage_ref(2:M+1,2:N+1)==IntegralImage_dut)) == M*N
    disp('test pass!');
else
    disp('test fail!');
end


integralImage_HDL = get(out.integralImage_HDL,'Data');
integralImage_HDL = reshape(integralImage_HDL,[320 240])';
sum(sum(IntegralImage_ref(2:M+1,2:N+1)==double(integralImage_HDL))) == M*N