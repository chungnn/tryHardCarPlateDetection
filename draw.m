clc;clear all;close all;
Img1 = imread('img/car10.jpg');
Img1 = imresize(Img1, [480 NaN]);
figure, imshow(Img1), title('origin image');

Img1BW = rgb2gray(Img1);
%figure, imshow(Img1BW), title('origin image');
%filterArr = [0 -1, 0; -1 5 -1; 0 -1 0];
%Img1BW = filter2(Img1BW, filterArr);
%figure, imshow(Img1BW), title('filter horiz');
%Img1BW = histeq(rgb2gray(Img1));
imbin = imbinarize(Img1BW);

Img1BW = edge(Img1BW, 'sobel');
%zeroImg = zeros(size(Img1BW));
figure, imshow(Img1BW), title('get edge');
%Img1BW = bwareaopen(Img1BW, 100);
%figure, imshow(Img1BW), title('after bwareaopen 1');
%zeroImg(150:318, 180:300) = 1;

%figure, imshow(bitand(zeroImg, Img1BW)), title('masked');
%Img1BW = bitand(zeroImg, Img1BW);
Img1BW = imdilate(Img1BW, strel('diamond', 2));
figure, imshow(Img1BW), title('after imdilate');
Img1BW = imfill(Img1BW, 'holes');
Img1BW = imerode(Img1BW, strel('diamond', 10));
figure, imshow(Img1BW), title('after erode');
%Img1BW = bwareaopen(Img1BW, 100);

%[L, num] = bwlabel(Img1BW);

bboxes = regionprops(Img1BW, 'BoundingBox','Area', 'Image');
area = bboxes.Area;
maxa = area;
boundingBox = bboxes.BoundingBox;
figure, imshow(Img1), title('with bounding box');
%hold on;
for k = 1: length(bboxes)
   curB = bboxes(k).BoundingBox;
   rectangle('Position', [curB(1), curB(2), curB(3), curB(4)], 'EdgeColor', 'r', 'LineWidth', 2);
   if maxa<bboxes(k).Area
       maxa=bboxes(k).Area;
       boundingBox=bboxes(k).BoundingBox;
   end
end
%hold off;

%get the plate
im = imcrop(imbin, boundingBox);
%resize number plate to 240 NaN
im = imresize(im, [240 NaN]);

%clear dust
im = imopen(im, strel('rectangle', [4 4]));
im2 = im;
im = bwareaopen(~im, 500);
%figure, imshow(im), title('before area open');
%remove some object if it width is too long or too small than 500
%im = bwareaopen(im, 100);

%figure, imshow(im), title('after area open');

%%%get width
 [h, w] = size(im);
% Iprops=regionprops(im,'BoundingBox','Area', 'Image');
% image = Iprops.Image;
% count = numel(Iprops);
% for i=1:count
%    ow = length(Iprops(i).Image(1,:));
%    if ow<(h/2) 
%         im = im .* ~Iprops(i).Image;
%    end
% end  


%read letter
Iprops = regionprops(im,'BoundingBox','Area', 'Image');
count = numel(Iprops);

noPlate=[]; % Initializing the variable of number plate string.

for i=1:count
   ow = length(Iprops(i).Image(1,:));
   oh = length(Iprops(i).Image(:,1));
   if ow<(h/2) & oh>(h/3)
       letter=readLetter(Iprops(i).Image); % Reading the letter corresponding the binary image 'N'.
       figure; imshow(Iprops(i).Image);
       noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
   end
end

if length(noPlate) < 1
    numOfTry = 1;
    while numOfTry <= 5 
        noPlate = tryHard(im2, numOfTry)
        numOfTry = numOfTry + 1;
        if length(noPlate) > 4
            noPlate
            break;
        end
    end
    
end