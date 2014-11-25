function prob = calcularPR(fp,hRAPA,x)
% Calculates the probability of a floor plan to have thus area.
prob = 1;

rooms = fp.getRooms;

% First, start calculating the probability of the floor plan.
% This envolves the probability of the number of rooms vs the area
% of the building. Lets create the histogram
jRAPAr = fp.getRoomAreas./fp.getArea;
hRAPAr = hist(jRAPAr,x);
hRAPAr = hRAPAr/sum(hRAPAr);

for i=1:length(rooms),
    room = rooms(i);
    area = rooms(i).getArea/fp.getArea;
    m = find(area>x, 1, 'last' );
    
    if isempty(m),
        d = 1-abs(hRAPAr(1)-hRAPA(1));
    else
        d = 1-abs(hRAPAr(m)-hRAPA(m));
    end
    room.setProbabilityArea(d);
    prob = prob*d;
end