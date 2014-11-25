function PBW = calcularPBR(fp,stat)

nRooms = fp.getNumberOfRooms;
nRoomsPlan = double(stat.numberOfRoomsPlan);

%y = poisspdf(sort(nRooms),m);

PBW = pdf('poiss',nRooms,mean(nRoomsPlan));
if PBW < realmin,
    PBW = realmin;
end


