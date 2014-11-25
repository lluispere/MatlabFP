function porta = hihaporta( part, npeaks, image )
%HIHAPORTA Summary of this function goes here
%   Detailed explanation goes here

if part.BoundingBox(4) > part.BoundingBox(3),
    
    x1 = ceil(part.BoundingBox(2));
    x2 = ceil(part.BoundingBox(2))+ceil(part.BoundingBox(4));
    y1 = ceil(part.BoundingBox(1)-part.BoundingBox(4));
    y2 = floor(part.BoundingBox(1)+part.BoundingBox(4));
    radii = part.BoundingBox(4):part.BoundingBox(4)+1;
    nhoodxy = part.BoundingBox(4);
    nhoodr = part.BoundingBox(4);
    if mod(radii(1),2) == 0,
        nhoodxy = nhoodxy*2-1;
        nhoodr = nhoodr-1;
    end
    xlowinteres = 1:floor(part.BoundingBox(4)*.20);
    xhighinteres = part.BoundingBox(4)+1:-1:part.BoundingBox(4)-floor(part.BoundingBox(4)*.20-1);
    xinteres = cat(2,xlowinteres,xhighinteres);
    yinteres = part.BoundingBox(4)-floor(part.BoundingBox(4)*.15):part.BoundingBox(4)+floor(part.BoundingBox(4)*.15);
else
    
    y1 = ceil(part.BoundingBox(1));
    y2 = ceil(part.BoundingBox(1))+ceil(part.BoundingBox(3));
    x1 = ceil(part.BoundingBox(2)-part.BoundingBox(3));
    x2 = floor(part.BoundingBox(2)+part.BoundingBox(3));
    radii = part.BoundingBox(3):part.BoundingBox(3)+1;
    nhoodxy = part.BoundingBox(3);
    nhoodr = part.BoundingBox(3);
    if mod(radii(1),2) == 0,
        nhoodxy = nhoodxy*2-1;
        nhoodr = nhoodr-1;
    end
    ylowinteres = 1:floor(part.BoundingBox(3)*.20);
    yhighinteres = part.BoundingBox(3)+1:-1:part.BoundingBox(3)-floor(part.BoundingBox(3)*.20)-1;
    yinteres = cat(2,ylowinteres,yhighinteres);
    xinteres = part.BoundingBox(3)-floor(part.BoundingBox(3)*.15):part.BoundingBox(3)+floor(part.BoundingBox(3)*.15);
end

if(x1 < 1)
    x1 = 1;
end
if(x2 > size(image,1)),
    x2 = size(image,1);
end
if(y1 < 1)
    y1 = 1;
end
if(y2 > size(image,2)),
    y2 = size(image,2);
end

imatgeretallada = image(x1:x2,y1:y2);

e = edge(imatgeretallada, 'canny');
%     e = ~imatgeretallada;
h1 = circle_hough(e, radii, 'same', 'normalise');
%     h1 = circle_hough(e, radii, 'same', 'normalise');
peaks = circle_houghpeaks(h1, radii, 'nhoodxy', nhoodxy, 'nhoodr', nhoodr, 'npeaks', npeaks,'Threshold',0.4);

porta = 0;
if size(peaks,2)
    if ismember(peaks(2),xinteres) && ismember(peaks(1),yinteres),
        porta = 1;
    end
end

end




