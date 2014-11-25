function drawWallsAndRooms(imageshed,name,folder,flag)

mkdir(folder);

if flag == 1 || flag == 3,
   
    parets = max(max(imageshed))-1;
    imageout = false(size(imageshed));
    imageout(imageshed==parets) = 1;
    imwrite(imageout,[folder name 'W.png'],'PNG');
    
end

if flag == 2 || flag == 3,
   
    hab = 1:max(max(imageshed))-2;
    imageout = false(size(imageshed));
    imageout(ismember(imageshed,hab)) = 1;
    imwrite(imageout,[folder name 'R.png'],'PNG');
    
end