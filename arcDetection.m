function arcDetection(carpetaInput)

% Script for detecting the walls and doors for in FP.
% Based on the detection of circles using the Hough Transform.



files = dir(carpetaInput);
files = files(3:length(files));

for i=1:length(files),
    name = files(i).name;
    if ~strcmp(name,'dades') && ~strcmp(name,'code');
        imoriginal = logical(imread(['../images/' name '.png']));
        
        load([carpetaInput '/' name '/results_final_' name '.mat']);
        load([carpetaInput '/' name '/results_final2_' name '.mat']);
        load([carpetaInput '/' name '/watershed.mat']);
        
        imseparadors1 = false(size(watershed1));
        imseparadors1(watershed1==2) = true;
        watershed3 = watershed1;
        
        imseparadors2 = false(size(watershed2));
        imseparadors2(watershed2==2) = true;
        watershed4 = watershed2;
        
        separadors1 = regionprops(imseparadors1,'BoundingBox','pixelIdxList');
        separadors2 = regionprops(imseparadors2,'BoundingBox','pixelIdxList');
        
        % intrinsec variables of the HT
        npeaks = 1;
        
        watershed3 = hihaporta(separadors1, watershed3, npeaks, imoriginal);
        watershed4 = hihaporta(separadors2, watershed4, npeaks, imoriginal);
        %     peaks = cat(2,peaks1,peaks2);
        %     save([carpetaResults nom(1:end-4)],'peaks');
        rgb = label2rgb(watershed3,'jet',[.5 .5 .5]);
        rgb2 = label2rgb(watershed4,'jet',[.5 .5 .5]);
        imwrite(rgb,[carpetaInput '/' name '/watershed5.png'],'PNG');
        imwrite(rgb2,[carpetaInput '/' name '/watershed6.png'],'PNG');
        save([carpetaInput '/' name '/portes'],'watershed3','watershed4');
    end
end