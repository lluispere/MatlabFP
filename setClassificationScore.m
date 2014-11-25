function setClassificationScore(fp,wResult)

ws = fp.getPrimitives();

for i=1:length(ws)
    if strcmp(ws(i).getType,'Wall'),
    % calculate the mean of the wall classifier
    image = fp.getRegionImage==ws(i).getId;
    wR = zeros(size(image));
    wR(image) = wResult(image);
    wR(wR==0) = [];
    if size(wR,2) == 0;
        wR=0;
    end
    ws(i).setClassOut(mean(wR));
    elseif strcmp(ws(i).getType,'Door'),
        ws(i).setClassOut(1);
    elseif strcmp(ws(i).getType,'Separation'),
        ws(i).setClassOut(1);
    end    
end