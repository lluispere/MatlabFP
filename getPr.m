function primitives = getPr(ws)
% This function calculates the matrix that associates the primitives to
% their respective attributes.

% we create the matrix structure
primitives = zeros(length(ws),3);

% for each primitive
for i=1:length(ws)
    primitives(i,1) = ws(i).getLength;
    if strcmp(ws(i).getType,'Wall'),
    % calculate the mean of the wall classifier
        primitives(i,2) = ws(i).getClassOut;
    elseif strcmp(ws(i).getType,'Door'),
        primitives(i,3)=ws(i).getClassOut;
    end
end