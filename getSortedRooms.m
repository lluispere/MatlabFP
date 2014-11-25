function jlist = getSortedRooms(fp)

roomCell = cell(fp.getRooms);
ids = cellfun(@(x) x.getId,roomCell);
ids = sort(ids);
jlist = java.util.ArrayList;
for i=1:size(ids,1),
    jlist.add(ids(i));
end
