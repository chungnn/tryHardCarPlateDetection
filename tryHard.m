function noPlate = tryHard(im2, numOfTry)
    noPlate = [];
    [x, y] = size(im2);
    zeroImg = zeros(size(im2));
    crop = numOfTry * 10;
    zeroImg(crop:x, :) = 1;
    %figure, imshow(im2), title('masked');
    %figure, imshow(bitand(zeroImg, im2)), title('masked');
    Img2BW = bitand(zeroImg, im2);
    figure, imshow(Img2BW), title('masked');
    Img2BW = edge(Img2BW, 'sobel');

    Img2BW = imdilate(Img2BW, strel('diamond', 3));
    %figure, imshow(Img2BW), title('after imdilate 2');
    Img2BW = imfill(Img2BW, 'holes');
    Img2BW = imerode(Img2BW, strel('diamond', 10));
    %figure, imshow(Img2BW), title('after erode');
    Img2BW = bwareaopen(Img2BW, 100);

    %figure, imshow(Img2BW), title('after bwareaopen 2');
    bboxes = regionprops(Img2BW, 'BoundingBox','Area', 'Image');
    area = bboxes.Area;
    maxa = area;
    boundingBox = bboxes.BoundingBox;
    %figure, imshow(im2), title('with bounding box');
    %hold on;
    for k = 1: length(bboxes)
       curB = bboxes(k).BoundingBox;
       rectangle('Position', [curB(1), curB(2), curB(3), curB(4)], 'EdgeColor', 'g', 'LineWidth', 1);
       if maxa<bboxes(k).Area
           maxa=bboxes(k).Area;
           boundingBox=bboxes(k).BoundingBox;
       end
    end
    %hold off;

    %get the plate
    im = imcrop(im2, boundingBox);
    %resize number plate to 240 NaN
    im = imresize(im, [200 NaN]);
    im = ~im;
    [h, w] = size(im);
    %read letter
    Iprops=regionprops(im,'BoundingBox','Area', 'Image');
    count = numel(Iprops);

    for i=1:count
       ow = length(Iprops(i).Image(1,:))
       oh = length(Iprops(i).Image(:,1))
       if oh > 50
           letter = readLetter(Iprops(i).Image); % Reading the letter corresponding the binary image 'N'.
           figure; imshow(Iprops(i).Image);
           noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
       end
    end

end