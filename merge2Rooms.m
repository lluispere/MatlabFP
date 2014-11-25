function [fp] = merge2Rooms(fp,rooms2merge,imageNewRoom,newRegionImage)
% This function merges two rooms in the floor plan given the floor plan
% (fp), the two rooms (r1, r2) and how the room image and floor plan image
% have to look like after the merging.

% first of all we create the new Room
rp = regionprops(imageNewRoom,'Area','Centroid','Perimeter','Extrema','BoundingBox');
roomId = min(cell2mat(cell(rooms2merge.toArray)));
room = rp(1);
jRoom = javaObject('prog.strelement.Room',roomId,room.Area,room.Centroid,room.Perimeter,room.Extrema,room.BoundingBox);

% now, the graph has to be update. To do so, we call the Java function
% merge2rooms from the floor plan
fp.mergeRooms(rooms2merge,jRoom,newRegionImage);
