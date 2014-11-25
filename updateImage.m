function [imageRoom, imagePlan] = updateImage(fp,rooms2mergeIds)
% This function calculates the new image for the room after merging r1 and
% r2 in th floor plan

id = min(cell2mat(cell(rooms2mergeIds.toArray)));

separationArray = cell(fp.getAllBordersBetweenRoomIds(rooms2mergeIds));

imageRoom = zeros(size(fp.getRegionImage));

rooms2mergeList = java.util.ArrayList;
rooms2mergeList.addAll(rooms2mergeIds);
for i=0:rooms2mergeIds.size-1,
    imageRoom(fp.getStructuralElementImageFromId(rooms2mergeList.get(i))) = 1;
end

for i = 1:size(separationArray,1),
    imageRoom(fp.getStructuralElementImage(separationArray{i})) = 1;
end

imagePlan = fp.getRegionImage;
imagePlan(logical(imageRoom)) = id;


