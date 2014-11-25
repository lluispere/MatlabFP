function PN = calcularPN(fp,stat)

pBNeighborConnected = fp.isConnected('neighbour');

if(pBNeighborConnected)
    PN = stat.neighborConnectivityP;
else PN = 1-stat.neighborConnectivityP;
    if PN == 0, PN = 0.01; end
end
if PN < realmin,
    PN = realmin;
end