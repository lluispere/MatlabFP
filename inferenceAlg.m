function inferenceAlg(fixedRoom,actualRoom,roomsToMerge,fp,stat,hRAPA,x,outFolder)
global cont jList jSet
%  main bucle in the algorithm
for i=1:roomsToMerge.size(),
    room2merge = roomsToMerge.get(i);
    % check wheather we have alredy tried this merging
    auxSet = getSortedRooms(fp);
    j = auxSet.indexOf(room2merge.getId);
    auxSet.remove(j);
    % if not, let's merge the rooms
    if ~jSet.contains(auxSet),
        jSet.add(auxSet);
        
        fp2 = fp.clone();

        % calculate the new image of the plan after the merging
        [imageRoom,imagePlan] = updateImage(fp2,actualRoom,room2merge);
        % merge the rooms in the plan graphs
        [fp2,actualRoom] = merge2Rooms(fp2,actualRoom,room2merge,imageRoom,imagePlan);
        
        % calculate the new probability
        [PFP,PB,PRAB,PWL,PWW,PBR,PRW,PA,PN,PWI] = calculateFPProbability(fp2,stat);
        
        % store image in disk
        image = fp2.drawImage;
        image = drawFPImageProb(image,PFP,PB,PRAB,PWL,PWW,PBR,PRW,PA,PN,PWI);
        rgb = label2rgb(image,'jet',[.5 .5 .5]);
        imwrite(rgb,[outFolder '/' num2str(cont) '.png'],'PNG');
        cont = cont+1;
        
        % store the probability
        jList.add(PFP);
        
        % calculate new roomsToMerge
        nRooms = fp2.getAccessGraph.getConnectedfVertexes(actualRoom);
        nRooms.remove(fixedRoom);
        inferenceAlg(actualRoom,nRooms,fp2,stat,hRAPA,x,outFolder);
    end
end

% delete the room if has no neighbors and calculate the probability
auxSet = getSortedRooms(fp);
j = auxSet.indexOf(actualRoom.getId);
auxSet.remove(j);
if ~jSet.contains(auxSet) && jSet.size>0,
    rSet = java.util.HashSet;
    rSet.add(actualRoom);
    fp2 = fp.clone();
    fp2.deleteASetOfRooms(rSet);
    % calculate the new probability
    [PFP,PB,PRAB,PWL,PWW,PBR,PRW,PA,PN,PWI] = calculateFPProbability(fp2,stat);
    % store image in disk
    image = fp2.drawImage;
    image = drawFPImageProb(image,PFP,PB,PRAB,PWL,PWW,PBR,PRW,PA,PN,PWI);
    rgb = label2rgb(image,'jet',[.5 .5 .5]);
    imwrite(rgb,[outFolder '/' num2str(cont) '.png'],'PNG');
    cont = cont+1;
    
    % store the probability
    jList.add(PFP);
end
