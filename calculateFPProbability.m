function [p] = calculateFPProbability(fp,stat,gmmA,gmmB,likelyhood,gmmC)
p = struct('PFP',[],'PB',[],'PRA',[],'PWL',[],'PWW',[],'PA',[],'PN',[],'PWI',...
    [],'PBR',[],'PRW',[],'enter',0);

if nargin < 6,
    p.PB=calcularPB(fp,gmmB);
else
    p.PB=calcularPB(fp,gmmC,1);
end
% Nou calcul de probabilitats:
% prob of the building element
% PBA = calcularPBA(fp,stat,gmmB);

% prob P(B,e) & P(B,w)
p.PRA = calcularPRA(fp,stat,gmmA);

% prob P(w,l)
p.PWL = calcularPWL(fp,likelyhood);

% prob P(w,w)
p.PWW = calcularPWW(fp,stat);
%PWW = 1;

% prob(B,v) prob(B,a)
p.PA = calcularPA(fp,stat);
p.PN = calcularPN(fp,stat);

% prob(Wi|I) = 1
%p.PWI = calcularPWI(fp);

% prob(B,n)
p.PBR = calcularPBR(fp,stat);

% prob(D,n)
% p.PDn = calcularPDn(fp);

% prob(H,n)
% p.PHn = calcularPHn(fp);


%% nou model
%p.PFP = p.PA*p.PN*p.PB*...
    %( p.PRA / (0.5^3) )*p.PWL*p.PWW*p.PBR;
p.PFP=log(p.PA)+log(p.PN)+log(p.PB)+log( p.PRA / (0.5^3) )+log(p.PWL)+log(p.PWW)+log(p.PBR);
% if p.PFP == 0,% && p.PRA > 0,
%     p.PFP = floor(log10(p.PA))+floor(log10(p.PN))...
%         +floor(log10(p.PB))+floor(log10(p.PRA))...
%         +floor(log10(p.PWL))+floor(log10(p.PWW))...
%         +floor(log10(p.PBR));
%     
%     pa = p.PA*10^-floor(log10(p.PA));
%     pn = p.PN*10^-floor(log10(p.PN));
%     pb = p.PB*10^-floor(log10(p.PB));
%     pra = p.PRA*10^-floor(log10(p.PRA));
%     pwl = p.PWL*10^-floor(log10(p.PWL));
%     pww = p.PWW*10^-floor(log10(p.PWW));
%     pbr = p.PBR*10^-floor(log10(p.PBR));
%     
%     p.enter = pa*pn*pb*pra*pwl*pww*pbr;
% end


% prob del FP
%%PFP = PB*PRAB*PWL*PWW*PBR*PRW*PA*PN*PWI;




% 
% % prob of the connectivity on the neighbour and access graphs
% pBNeighbourConnected = fp.isConnected('neighbour');
% pBAccessConnected = fp.isConnected('access');
% if(pBNeighbourConnected)
%     pBN = stat.neighborConnectivityP;
% else pBN = 1-stat.neighborConnectivityP;
% end
% if(pBAccessConnected)
%     pBA = stat.neighborConnectivityP;
% else pBA = 1-stat.neighborConnectivityP;
% end
% 
% % probability of the building given the rooms
% pBR = calcularPBR(fp,hRAPA,x);
% 
% % probability of each room
% pR = calcularPR(fp,hRAPA,x);
% 
% % probability of the room given its formation
% pRWS = fp.calculateRoomsProbDist(stat);
% 
% % final probability
% pFP = pB*pBR*pR*pRWS;