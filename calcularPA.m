function PA = calcularPA(fp,stat)

pBAccessConnected = fp.isConnected('access');

if(pBAccessConnected)
    PA = stat.accessConnectivityP;
else PA = 1-stat.accessConnectivityP;
    if PA == 0, PA = 0.01; end
end
if PA < realmin,
    PA = realmin;
end