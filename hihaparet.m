function paret = hihaparet( part, thrs, image, sepImage )

x1 = ceil(part.BoundingBox(2));
y1 = ceil(part.BoundingBox(1));
x2 = ceil(part.BoundingBox(2))+ceil(part.BoundingBox(4))-1;
y2 = ceil(part.BoundingBox(1))+ceil(part.BoundingBox(3))-1;

wallImage = image(x1:x2,y1:y2);

wallMembers = wallImage(part.Image);

if mean(wallMembers)>thrs,
    paret = 1;
else
    paret = 0;
end