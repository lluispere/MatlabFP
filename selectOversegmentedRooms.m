function rSet = selectOversegmentedRooms(fp,hRAPA,x)
rooms = fp.getRooms;
% First, start calculating the probability of the floor plan.
% This envolves the probability of the number of rooms vs the area
% of the building. Lets create the histogram
jRAPAr = fp.getRoomAreas./fp.getArea;
hRAPAr = hist(jRAPAr,x);
hRAPAr = hRAPAr/sum(hRAPAr);
rSet = cell(0);

for i=1:length(rooms),
    room = rooms(i);
    area = rooms(i).getArea/fp.getArea;
    m = find(area>x, 1, 'last' );
    
    if isempty(m),
        d = hRAPA(1)-hRAPAr(1);
    else
        d = hRAPA(m)-hRAPAr(m);
    end
    if d<0,
        rSet(end+1) = room;
    end
end