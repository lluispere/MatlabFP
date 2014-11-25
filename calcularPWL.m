function PWL = calcularPWL(fp,B)
PWL = 1;

ws = fp.getPrimitivesNothing;

primitives = getPr(ws);

py = mnrval(B,primitives);

% for each primitive
for i=1:length(ws)
    if strcmp(ws(i).getType,'Wall')
        PWL = PWL*py(i,1);
    elseif strcmp(ws(i).getType,'Door')
        PWL = PWL*py(i,2);
    elseif strcmp(ws(i).getType,'Separation')
        PWL = PWL*py(i,3);
    else PWL = PWL*py(i,4);
    end
end

if PWL < realmin,
    PWL = realmin;
end




% suave = 0.01;
% pWalls = 1;
% pDoors = 1;
% pSeps = 1;
% 
% A = double(stat.samplingConfiguration);
% B = A/sum(A(:));
% B = B+suave;
% B = B/sum(B(:));
% sumB = sum(B);
% pW = sumB(1);
% pD = sumB(2);
% pS = sumB(4);
% 
% %[muhatW,sigmahatW] = normfit(lWalls);
% %[muhatD,sigmahatD] = normfit(lDoors);
% %[muhatS,sigmahatS] = normfit(lSep);
% 
% walls = fp.getWalls;
% doors = fp.getDoors;
% seps = fp.getSeparations;
% 
% %p=[];
% for i=1:length(walls)
%     wall = walls(i);
%     l = calculateLength(wall,fp);
%     plw = objW.pdf(l);
%     pld = objD.pdf(l);
%     pls = objS.pdf(l);
%     %     plw = pdf('normal',l,muhatW,sigmahatW);
%     %     pld = pdf('normal',l,muhatD,sigmahatD);
%     %     pls = pdf('normal',l,muhatS,sigmahatS);
%     %     p(end+1)=(plw*pW/(pld*pD + pls*pS + plw*pW ));
%     %     if p(end) < .3
%     %         keyboard
%     %     end
%     prod = (plw*pW/(pld*pD + pls*pS + plw*pW ));
%     if prod > 1/3,
%         pWalls = pWalls*( prod );
%     end
% end
% 
% for i=1:length(doors)
%     door = doors(i);
%     l = calculateLength(door,fp);
%     plw = objW.pdf(l);
%     pld = objD.pdf(l);
%     pls = objS.pdf(l);
%     %     plw = pdf('normal',l,muhatW,sigmahatW);
%     %     pld = pdf('normal',l,muhatD,sigmahatD);
%     %     pls = pdf('normal',l,muhatS,sigmahatS);
%     %      p(end+1)=(pld*pD/(pld*pD + pls*pS + plw*pW ));
%     prod = (pld*pD/(pld*pD + pls*pS + plw*pW ));
%     if prod > 1/3,
%         pDoors = pDoors*( prod );
%     end
% end
% 
% for i=1:length(seps)
%     sep = seps(i);
%     l = calculateLength(sep,fp);
%     plw = objW.pdf(l);
%     pld = objD.pdf(l);
%     pls = objS.pdf(l);
%     %     plw = pdf('normal',l,muhatW,sigmahatW);
%     %     pld = pdf('normal',l,muhatD,sigmahatD);
%     %     pls = pdf('normal',l,muhatS,sigmahatS);
%     %      p(end+1)=(pls*pS/(pld*pD + pls*pS + plw*pW ));
%     prod = (pls*pS/(pld*pD + pls*pS + plw*pW )) ;
%     if prod > 1/3,
%         pSeps = pSeps*( prod );
%     end
% end
% 
% PWL = pWalls*pDoors*pSeps;