function PDn = calcularPDn(fp)

load ./CreateStatistics/statistics/black.mat;
wallsInDomains = double(numberOfElementsOfDomains(1,:)');
doorsInDomains = double(numberOfElementsOfDomains(2,:)');
sepsInDomains = double(numberOfElementsOfDomains(3,:)');

load ./CreateStatistics/statistics/textured.mat;
wallsInDomains = cat(2,wallsInDomains,double(numberOfElementsOfDomains(1,:)'));
doorsInDomains = cat(2,doorsInDomains,double(numberOfElementsOfDomains(2,:)'));
sepsInDomains = cat(2,sepsInDomains,double(numberOfElementsOfDomains(3,:)'));

load ./CreateStatistics/statistics/textured2.mat;
wallsInDomains = cat(2,wallsInDomains,double(numberOfElementsOfDomains(1,:)'));
doorsInDomains = cat(2,doorsInDomains,double(numberOfElementsOfDomains(2,:)'));
sepsInDomains = cat(2,sepsInDomains,double(numberOfElementsOfDomains(3,:)'));

load ./CreateStatistics/statistics/parallel.mat;
wallsInDomains = cat(2,wallsInDomains,double(numberOfElementsOfDomains(1,:)'));
doorsInDomains = cat(2,doorsInDomains,double(numberOfElementsOfDomains(2,:)'));
sepsInDomains = cat(2,sepsInDomains,double(numberOfElementsOfDomains(3,:)'));

for i=1:length(rooms),
    r = rooms(i);
    
    nWall = fp.getNumberOfElementsAtRoom(r,'Wall');
    nDoor = fp.getNumberOfElementsAtRoom(r,'Door');
    nSep = fp.getNumberOfElementsAtRoom(r,'Separation');
    
    pw = pdf('poiss',nWall,mean(wallsInDomains));
    pd = pdf('poiss',nDoor,mean(doorsInDomains));
    ps = pdf('poiss',nSep,mean(sepsInDomains));
    
    PDn = pw*pd*ps;
end
