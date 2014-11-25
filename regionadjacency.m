function  [finalAssignements] = regionadjacency(image,maxpixels)

im = image;
im(sum(image,2)==0,:) = [];
im(:,sum(image,1)==0) = [];

%% horizontal connections

cellImage = num2cell(im,2);
[consecutiveValues,frequency] = cellfun(@RunLength_M,cellImage,'UniformOutput', false);
overseparation = cellfun(@(x,y)  intersect(find(x==-1),find(y>maxpixels)),consecutiveValues,frequency,'UniformOutput', false);
clearedOverseparation = cellfun(@(x,y) assignar(x,y),consecutiveValues,overseparation,'UniformOutput', false);
clearedOverseparation2 = cellfun(@(x) netejar(x),clearedOverseparation,'UniformOutput', false);
finalCellHorAssignements = cellfun(@(x) [x(1:end-1)',x(2:end)'],clearedOverseparation2,'UniformOutput', false);

%% vertical connections

cellImage = num2cell(im',2);
[consecutiveValues,frequency] = cellfun(@RunLength_M,cellImage,'UniformOutput', false);
overseparation = cellfun(@(x,y)  intersect(find(x==-1),find(y>maxpixels)),consecutiveValues,frequency,'UniformOutput', false);
clearedOverseparation = cellfun(@(x,y) assignar(x,y),consecutiveValues,overseparation,'UniformOutput', false);
clearedOverseparation2 = cellfun(@(x) netejar(x),clearedOverseparation,'UniformOutput', false);
finalCellVerAssignements = cellfun(@(x) [x(1:end-1)',x(2:end)'],clearedOverseparation2,'UniformOutput', false);

%% join the connections 

finalAssignements = cell2mat(finalCellHorAssignements);
finalAssignements = cat(1,finalAssignements,cell2mat(finalCellVerAssignements));
finalAssignements(finalAssignements(:,1)==0,:) = [];
finalAssignements(finalAssignements(:,2)==0,:) = [];
finalAssignements(finalAssignements(:,1)==finalAssignements(:,2),:) = [];
finalAssignements = sort(finalAssignements,2);
finalAssignements = unique(finalAssignements,'rows');


end 

function x = assignar(x,y)
    x(y) = 0;
end

function y = netejar(x)
    y = x;
    y(x==-1) = [];
end