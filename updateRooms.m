function fp = updateRooms(fp,hRAPA,x)
% This funcitions choses a candidate that will be merged with one of its
% neighbours.

% Get the rooms
rooms = fp.getRooms;

%% Check if there is a room not accessible, isolated. In that case, it has
% to be removed from the floor plan

notConnectedRooms = fp.getRoomNotConnected('Access');

if notConnectedRooms.size > 0,
    % delete those unconected rooms
    fp.deleteASetOfRooms(notConnectedRooms);
else
    
    %% Select the most unprobable room in terms of its area and distribution
    
    roomsCell = cell(rooms);
    % the rooms selected are those tha are too many in the histogram of areas
    selectedRooms = selectOversegmentedRooms(fp,hRAPA,x);
    
    if size(selectedRooms,1) > 0,
        roomsCell = selectedRooms;
    end
    
    probDist = cellfun(@(x) x.getProbabilityDist(), roomsCell);
    probArea = cellfun(@(x) x.getProbabilityArea(), roomsCell);
    fp.calculateDSVSArea();
    distVSArea = cellfun(@(x) 1-x.getDSVSArea(), roomsCell);
    prob = distVSArea.*probDist.*probArea;
    
    % select those with the lowest probability
    indx = prob==min(prob);
    restRoomsCell = roomsCell(indx);
    
    % among them, the one with the lowest area
    areas = cellfun(@(x) x.getArea(), restRoomsCell);
    [~, i] = sort(areas);
    
    roomSelected = restRoomsCell{i(1)};
    
    %% Now we have to select the less probable neighbour to merge it. It has
    % to be accessible from it.
    
    % get the accessible Rooms from the selected Room
    graph = fp.getAccessGraph;
    connectedRooms = graph.getConnectedfVertexes(roomSelected);
    
    % select that one that has the lower P or has the smallest area.
    if size(connectedRooms,1) == 1,
        % merge the 2 rooms to generate the new image room for both, the room
        % and the plan
        [imageRoom,imagePlan] = updateImage(fp,roomSelected,connectedRooms(1));
        % merge the rooms in the plan graphs
        fp = merge2Rooms(fp,roomSelected,connectedRooms(1),imageRoom,imagePlan);
    else
        connectedRooms = cell(connectedRooms);
        probDist = cellfun(@(x) x.getProbabilityDist(), connectedRooms);
        probArea = cellfun(@(x) x.getProbabilityArea(), connectedRooms);
        prob = probDist.*probArea;
        indx = prob==min(prob);
        connectedRooms = connectedRooms(indx);
        if size(connectedRooms,1) == 1
            % merge the 2 rooms to generate the new image room for both, the room
            % and the plan
            [imageRoom,imagePlan] = updateImage(fp,roomSelected,connectedRooms{1});
            % merge the rooms in the plan graphs
            fp = merge2Rooms(fp,roomSelected,connectedRooms{1},imageRoom,imagePlan);
        else
            % among them, the one with the lowest area
            areas = cellfun(@(x) x.getArea(), connectedRooms);
            [~, i] = sort(areas);
            % merge the 2 rooms to generate the new image room for both, the room
            % and the plan
            [imageRoom,imagePlan] = updateImage(fp,roomSelected,connectedRooms{i(1)});
            % merge the rooms in the plan graphs
            fp = merge2Rooms(fp,roomSelected,connectedRooms{i(1)},imageRoom,imagePlan);
        end
    end
end