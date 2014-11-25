function prob = calcularPB(fp,obj,flag)
% Calculates the probability of a floor plan to have thus area.
if nargin ==2
    % Calculates the probability of a floor plan to have thus area.
    prob = obj.pdf(fp.getArea);
    if prob==0,
        prob = realmin;
    end
else
    prob=1;
    arees = fp.getConnectedAreas(fp.getConnectedGraphs('access'));
    for i=1:arees.length(),
        prob = prob*obj.pdf(double(arees(i)));
    end
end

% y = pdf('normal',arees,muhat,sigmahat);
% % normalization
% y = y/max(y);
% 
% m = find(arees<fp.getArea, 1, 'last' );
% 
% if isempty(m),
%     prob = y(1);
% else
%     prob = y(m);
% end







