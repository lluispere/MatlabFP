function l = calculateLength(obj,fp)
% This function calculates an approximation of the length of an object OBJ
% in a floor plan FP. It is done by calculating the maximul length component
% of its BB. This length is normalized by the square
% root of the area of FP

image = fp.getRegionImage==obj.getId;
stat = regionprops(image,'MajorAxisLength');
if size(stat,1)>0;
    l = stat(1).MajorAxisLength;
    l = l/sqrt(fp.getArea);
else l = 1;
end


% id = obj.getId;
% fpImage = fp.getRegionImage;
% 
% objImage = zeros(size(fpImage));
% objImage(fpImage==id) = 1;
% 
% skel = bwmorph(objImage,'skel',Inf);
% 
% l = sum(sum(skel));
% l = l/sqrt(fp.getArea);


