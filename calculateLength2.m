function l = calculateLength2(obj,fp)
% This function calculates an approximation of the length of an object OBJ
% in a floor plan FP. It is done by calculating the skeleton of the object
% image and adding all the pixels. This length is normalized by the square
% root of the area of FP

% image = false(size(fp.getRegionImage));
% image(fp.getRegionImage==obj.getId) = true;
% stat = regionprops(image,'MajorAxisLength');
% l = stat(1).MajorAxisLength;
% l = l/sqrt(fp.getArea);


id = obj.getId;
fpImage = fp.getRegionImage;

objImage = zeros(size(fpImage));
objImage(fpImage==id) = 1;

skel = bwmorph(objImage,'skel',Inf);

l = sum(sum(skel));
l = l/sqrt(fp.getArea);