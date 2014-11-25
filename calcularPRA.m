function PRA = calcularPRA(fp,stat,obj)

PR1 = 1/2;
PR0 = 1- PR1;
PAR0 = 10^-5;
PRA = 1;

wallsInRooms = double(stat.numberOfWallsRoom);
doorsInRooms = double(stat.numberOfDoorsRoom);
sepsInRooms = double(stat.numberOfSeparationsRoom);
nothsInRooms = double(stat.numberOfNothingsRoom);

rooms = fp.getRooms;

%[muhat,sigmahat] = normfit(arees);

for i=1:length(rooms),
    r = rooms(i);
    
    % calculus of the pdf of the building areas
    PAR1=obj.pdf(fp.getRoomArea(r));
    %PAR1 = pdf('normal',fp.getRoomArea(r),muhat,sigmahat);
    
    nWall = fp.getNumberOfElementsAtRoom(r,'Wall');
    nDoor = fp.getNumberOfElementsAtRoom(r,'Door');
    nSep = fp.getNumberOfElementsAtRoom(r,'Separation');
    nNoth = fp.getNumberOfElementsAtRoom(r,'Nothing');
    
    pw = pdf('poiss',nWall,mean(wallsInRooms));
    pd = pdf('poiss',nDoor,mean(doorsInRooms));
    ps = pdf('poiss',nSep,mean(sepsInRooms));
    pn = pdf('poiss',nNoth,mean(nothsInRooms));
    
    PRA = PRA*(1/( (PAR0*PR0)/(PAR1*pw*pd*ps*pn*PR1)+ 1));
end

if  PRA < realmin,
    PRA = realmin;
end