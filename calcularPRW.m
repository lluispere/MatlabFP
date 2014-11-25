function PRW = calcularPRW(fp,stat)

PRW = 1;
wallsInRooms = double(stat.numberOfWallsRoom);
doorsInRooms = double(stat.numberOfDoorsRoom);
sepsInRooms = double(stat.numberOfSeparationsRoom);

% nWalls = stat.numberOfCCWalls;
% nDoors = stat.numberOfCCDoors;
% nSep = stat.numberOfCCSeparations;

rooms = fp.getRooms;
pWalls=1;
pDoor=1;
pSep=1;
for i=1:length(rooms),
    r = rooms(i);
    nWall = fp.getNumberOfElementsAtRoom(r,'Wall');
    nDoor = fp.getNumberOfElementsAtRoom(r,'Door');
    nSep = fp.getNumberOfElementsAtRoom(r,'Separation');
    
    pw = pdf('poiss',nWall,mean(wallsInRooms));
    pd = pdf('poiss',nDoor,mean(doorsInRooms));
    ps = pdf('poiss',nSep,mean(sepsInRooms));
    
%     total = (pd*pD + ps*pS + pw*pW );
    
%     pWalls = pWalls*( pw*pW/total  );    
%     pDoor = pDoor*( pd*pD/total  );
%     pSep =pSep*( ps*pS/total  );
end


PRW = PRW*pWalls*pDoor*pSep;

