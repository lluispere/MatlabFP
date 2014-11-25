function floorplanInterpreter(fitxerInput)

% Floor plan interpreter
% Function to interpret floor plans

%% Run vlfeat

run('D:/Doctorat/FinalFloorPlanInterpretation/2014/vlfeat-0.9.19/toolbox/vl_setup');

%% Load JAVA statistics
directoryGT = 'D:\Doctorat\FinalFloorPlanInterpretation\2014\groundtruth\svg';
directoryForce = 'D:\Doctorat\FinalFloorPlanInterpretation\2014\Force';
jMATreadobj = javaObject('prog.matlab.ReadStatistics',directoryGT,directoryForce);
jSTATobj = jMATreadobj.readFPStatistics;

%% Create output folder
mkdir D:/Doctorat/FinalFloorPlanInterpretation/2014/Results

%% Specify parameters
% this parameters states the minimum certainty to consider a separation a
% wall in the wall detection image.
thrs = 0.30;

%% Program is starting
disp '-> Let´s go!';

%% Create the AND representation from the walls and watershed

initialFP = 'D:/Doctorat/FinalFloorPlanInterpretation/2014/floorplans';

% store the initial part
if ~isdir(initialFP),
    mkdir(initialFP);
end

% lecture
dircontent=dir(fitxerInput);
fnames=dircontent(3:size(dircontent,1));
clear dircontent;



% op. per a cada imatge
for n=1:size(fnames,1),
    name = fnames(n).name;
    % create results folder
    outFolder = ['D:/Doctorat/FinalFloorPlanInterpretation/2014/Results/' name];
    mkdir(outFolder);
    
    % check for the existence of a preload floor plan
    if exist([initialFP '/' name '.java'],'file') ~= 2
        
        imOriginal = boolean(imread(['D:/Doctorat/FinalFloorPlanInterpretation/2014/Images/' name '.png']));
        imO(:,:) = imOriginal(:,:,1);
        imOriginal = imO;
        if sum(sum(imOriginal==1))>sum(sum(imOriginal==0)),
            imOriginal = ~imOriginal;
        end
        
        
        % crear el Floor Plan
        jFloorPlan = javaObject('prog.strelement.FloorPlan',name);
        
        if ~strcmp(name,'code') && ~strcmp(name,'dades'),
            load([fitxerInput '/' name '/results_final_' name]);
            load([fitxerInput '/' name '/results_final2_' name]);
            % clear impossible walls from the plan at the beginning
            % this is done in function to the size of the pixles when
            % finding walls between parallel lines
            maxpixels = max(cellfun(@max,pixels));
            ccprops = regionprops(imatgeFinal2,'Area','PixelIdxList');
            for i=ccprops',
                if i.Area <= maxpixels^2,
                    imatgeFinal2(i.PixelIdxList) = 0;
                end
            end
            
            imatgeFinal2 = imresize(imatgeFinal2,size(imOriginal));
            mwflFinal2 = imresize(mwflFinal2,size(imOriginal));
            
            % clear the hight amount of variables not used in the context
            clearvars -except jSTATobj jFloorPlan fitxerInput imatgeFinal2...
                pixels fnames name jRAPA x hRAPA outFolder imOriginal thrs...
                mwflFinal2 maxpixels cont jList initialFP initialST
            
            namefinal = [fitxerInput '/' name '/'];
            
            jFloorPlan.setHeight(size(imatgeFinal2,1));
            jFloorPlan.setWidth(size(imatgeFinal2,2));
            
            %imwrite(imatgeFinal,[namefinal 'proces1.png'],'PNG');
            %imwrite(imatgeFinal2,[namefinal 'proces2.png'],'PNG');
            
            %% Calculus of watershed BoVW
            
            bw = ~imatgeFinal2;
            D = bwdist(~bw,'cityblock');
            D(~bw) = Inf;
            D = -D;
            L = watershed(D);
            
            % Watershed clean
            pdist = bwdist(imatgeFinal2);
            pos1 = false(size(L));
            pos2 = false(size(L));
            pos1(L==0) = 1;
            pos2(pdist<2) = 1;
            cF = imatgeFinal2;
            cF(and(pos1,pos2)) = 1;
            
            % Delete limit regions with the borders of the image
            l = L;
            maximMesU = max(max(l))+1;
            l(l==0) = maximMesU;
            t = unique(l(1,:));
            t(t==maximMesU)=[];
            for i=t,
                l(l==i) = 0;
            end
            d = unique(l(end,:));
            d(d==maximMesU)=[];
            for i=d,
                l(l==i) = 0;
            end
            le = unique(l(:,1))';
            le(le==maximMesU)=[];
            for i=le,
                l(l==i) = 0;
            end
            ri = unique(l(:,end))';
            ri(ri==maximMesU)=[];
            for i=ri,
                l(l==i) = 0;
            end
            
            % Delete the separators to the limits of the image and other
            % possible artifacts
            separadors = false(size(cF));
            separadors(l==maximMesU) = true;
            separadors(cF) = false;
            ccprops = regionprops(separadors,'Extrema','PixelIdxList');
            for i=ccprops',
                minim = floor(min(i.Extrema));
                maxim = floor(max(i.Extrema));
                if sum(minim==0)>0 ||...
                        sum(maxim(2)==size(cF,1))>0 ||...
                        sum(maxim(1)==size(cF,2))>0,
                    separadors(i.PixelIdxList) = 0;
                end
            end
            ccprops = regionprops(separadors,'Area','PixelIdxList');
            for i=ccprops',
                if i.Area <= 2,
                    separadors(i.PixelIdxList) = 0;
                end
            end
            
            % Create the region image. The background of this image is 0, the
            % regions are labelled from 1 to n. The walls has label n+1 and
            % separators n+2
            finalshed = double(l);
            finalshed(finalshed == max(max(finalshed))) = 0;
            finalshed(cF) = 0;
            finalshed = bwlabel(finalshed);
            roomImage = finalshed;
            finalshed(cF) = max(max(finalshed))+1;
            finalshed(separadors) = max(max(finalshed))+1;
            
            %drawWallsAndRooms(finalshed,name,'../ResultsRAW/',2);
            
            % Create the image in appropriate format to calculate the RAG. This
            % image has 0 in the background and -1 on walls and separators
            image2RAG = finalshed;
            image2RAG(image2RAG==max(max(image2RAG))) = -1;
            image2RAG(image2RAG==max(max(image2RAG))) = -1;
            
            % Room adjacency table
            roomAdjacency = regionadjacency(image2RAG,maxpixels);
            
            % Get the image of walls and separations to get their adjacency.
            % The pixel label is the id of the element.
            wallImage = finalshed==max(max(finalshed))-1;
            wallImage = bwlabel(wallImage);
            wallImage(wallImage>0) =  wallImage(wallImage>0)+max(max(finalshed))-2;
            sepImage = finalshed==max(max(finalshed));
            sepImage = bwlabel(sepImage);
            sepImage(sepImage>0) = sepImage(sepImage>0)+max(max(wallImage));
            wallSepImage = wallImage+sepImage;
            
            % Create the final image with all the structuralElements Labels
            regionImage = wallSepImage+roomImage;
            
            % Room, Wall, and separation adjacency table
            adjacency = regionadjacency(regionImage,1);
            
            % Concatenate both adjacency matrices
            adjacency = cat(1,roomAdjacency,adjacency);
            adjacency = unique(adjacency,'rows');
            
            % Set the image and the regionAdjacency in the floor plan;
            jFloorPlan.setRegionImage(regionImage);
            jFloorPlan.setAdjacencyMatrix(adjacency);
            
            % clear dead vars
            clear separadors l finalshed wallSepImage adjacency...
                roomAdjacency regionadjacency image2RAG cF bw L D pdist pos1...
                pos2
            
            %% Start to create the and-graph in JAVA.
            % First, the structural elements are add to the floor plan
            % arraylist in JAVA. Then the adjacency matrices. Finally, the
            % graph is constructed.
            
            % room constructor
            r = regionprops(roomImage,'Area','Centroid','Perimeter','Extrema','BoundingBox');
            % the same is done for walls
            r2 = regionprops(logical(wallImage),'Area','FilledImage','Centroid','Perimeter','Extrema','MajorAxisLength','BoundingBox');
            % the same is done for walls
            r3 = regionprops(logical(sepImage),'Area','FilledImage','BoundingBox','Image','Centroid','Perimeter','Extrema','MajorAxisLength','MinorAxisLength');
            
            % for each room we add it to the floor plan
            for i=1:length(r),
                room = r(i);
                jRoom = javaObject('prog.strelement.Room',i,room.Area,room.Centroid,room.Perimeter,room.Extrema,room.BoundingBox);
                jFloorPlan.addStructuralElement(jRoom);
            end
            
            % for each wall we add it to the floor plan
            for j=1:length(r2),
                wall = r2(j);
                wThickness = max(max(bwdist(~wall.FilledImage)));
                jWall = javaObject('prog.strelement.Wall',i+j,wall.Area,wall.Centroid,wall.Perimeter,wall.Extrema,wThickness,max(size(wall.FilledImage)),wall.BoundingBox);
                jFloorPlan.addStructuralElement(jWall);
            end
            
            % for each separation we add it to the floor plan
            for c=1:length(r3),
                sep = r3(c);
                porta = hihaporta(sep,1,imOriginal);
                if porta == 0,
                    paret = hihaparet(sep,thrs,mwflFinal2,sepImage);
                    if paret == 0,
                        jObj = javaObject('prog.strelement.Separation',i+j+c,sep.Area,sep.Centroid,sep.Perimeter,sep.Extrema,max(size(sep.FilledImage)),sep.BoundingBox);
                    else
                        jObj = javaObject('prog.strelement.Wall',i+j+c,sep.Area,sep.Centroid,sep.Perimeter,sep.Extrema,min(size(sep.FilledImage)),max(size(sep.FilledImage)),sep.BoundingBox);
                    end
                else
                    jObj = javaObject('prog.strelement.Door',i+j+c,sep.Area,sep.Centroid,sep.Perimeter,sep.Extrema,max(size(sep.FilledImage)),sep.BoundingBox);
                end
                jFloorPlan.addStructuralElement(jObj);
            end
            
            %% clean the memory
            
            clearvars -except jFloorPlan jSTATobj hRAPA x fitxerInput imatgeFinal2...
                pixels fnames name outFolder thrs cont jList mwflFinal2 initialFP...
                initialST
            
            %% Create the graph in java for starting the interpretation
            jFloorPlan.createGraphs();
            
            % first of all, clean those rooms that their area is 0
            jFloorPlan.cleanVerySmallRooms(10);
            
            % secon of all, clean those rooms that are isolated
            jFloorPlan.cleanIsolatedRooms();
            
            % set the classification out for the primitives
            setClassificationScore(jFloorPlan,mwflFinal2);
            
            jfpio = javaObject('prog.io.FloorPlanIO');
            jfpio.storeFloorPlan(jFloorPlan,[initialFP '/' name '.java']);
        end
        
    else
        jfpio = javaObject('prog.io.FloorPlanIO');
        jFloorPlan = jfpio.loadFloorPlan([initialFP '/' name '.java']);
    end
    
    %% Start the main algorithm
    
    % calculus of the GMM for the model
    %% calcul de GMM
    % GMM sobre les arees de les habitacions
    Ka = 10;
    Kb = 2;
    Kc = 4;
    arees = sort(double(jSTATobj.roomsAreas));
    areaB = sort(double(jSTATobj.areas));
    gmmA = gmdistribution.fit(arees,Ka,'Regularize',eps);
    gmmB = gmdistribution.fit(areaB,Kb,'Regularize',eps);
    numOfBuildings = round(mean(double(jSTATobj.numOfBuildings)));
    areaC = sort(double(jSTATobj.areasOfBuildingsPlan));
    gmmC = gmdistribution.fit(areaC,Kc,'Regularize',eps);
    
    
    % GMM sobre la longitud dels elements
    Kw = 50;
    Kd = 10;
    Ks = 5;
    %         gmmW = gmdistribution.fit(lWalls,Kw,'Regularize',1e-10);
    %         gmmD = gmdistribution.fit(lDoors,Kd,'Regularize',1e-10);
    %         gmmS = gmdistribution.fit(lSep,Ks,'Regularize',1e-10);
    
    % likelihood learning
    X = double(jSTATobj.likelyhoodX);
    Y = double(jSTATobj.likelyhoodY);
    likelyhood = mnrfit(X,Y);
    
    % calculate the probability of the floor plan in the actual state.
    % This is P(B)*P(B|R-R)*P(R)*P(R|W--S), wherD:
    % P(B) is the area of the plan given the areas
    % P(B|R) is the distribution of the area of the rooms
    % P(R) is the area of the room in the distribution
    % P(R|W-S) is the potential function.
    cont = 1;
    jList = java.util.ArrayList;
    jConfList = java.util.ArrayList;
    bestProb = calculateFPProbability(jFloorPlan,jSTATobj,gmmA,gmmB,likelyhood);
    jList.add(bestProb.PFP);
    
    % store the rooms ids for this plan
    jConfList.add([]);
    
    image = jFloorPlan.drawImage;
    image = drawFPImageProb(image,bestProb);
    rgb = label2rgb(image,'jet',[.5 .5 .5]);
    imwrite(rgb,[outFolder '/' num2str(cont) '.png'],'PNG');
    cont = cont+1;
    
    %% Start the dynamic algorithm
    
    % get all the valid composition of the floor plan rooms agreeing
    % with their neighborhood
    disp('-> calculant el primer merging');
    allValidMergings = jFloorPlan.calculateAllValidRoomMergingsOfDegree(2);
    PFPAnt = 0;
    jSet = java.util.HashSet;
    fp = jFloorPlan;
    
    while (allValidMergings.size > 0),
        disp(['-> calculat el primer merging ' num2str(allValidMergings.size)]);
        if allValidMergings.size == 9,
            a = 0;
        end
            
        %fp = clone(newFP);
        PFPAnt = bestProb.PFP;
        oldfp = fp.clone;
        oldprob = bestProb;
        %             listOfFP = java.util.ArrayList;
        %             listOfProbs = [];
        bestProb=[];
        
        % bar things
        %             h = waitbar(0,'Please wait...');
        %             barstate = 0;
        %             barsteps = allValidMergings.size;
        for j=0:allValidMergings.size-1;

            validMerging = allValidMergings.get(j);
            %                 if (~jSet.contains(validMerging)),
            % get the Ids of the rest of the rooms that are not merged
            restOfRooms = fp.getRestOfRoomsIds(validMerging);
            % get the minimum idx of the rooms to merge
            minRoomMergingIdx =  min(cell2mat(cell(validMerging.toArray)));
            % get the final configuration of the rooms
            restOfRooms.add(uint32(minRoomMergingIdx));
            % calculate the floor plan configuration & probability
            [newFP,p] = newFloorPlanComposition(fp,validMerging,jSTATobj,gmmA,gmmB,likelyhood);
            % cat the probability for the floor plan
            %                 listOfProbs = cat(1,listOfProbs,p);
            %                 end
            if isempty(bestProb),
                bestProb = p;
                bestFP = newFP.clone;
                vM = validMerging;
            elseif  (p.PFP > bestProb.PFP) ||...
                    (bestProb.PFP == oldprob.PFP && bestProb.enter > oldprob.enter &&...
                        bestProb.PFP < 0 && oldprob.PFP < 0),
                bestProb = p;
                bestFP = newFP.clone;
                vM = validMerging;
            end
            %                 waitbar(barstate / barsteps)
            %                 barstate = barstate+1;
        end
        %             close(h);
        if(oldprob.PFP < bestProb.PFP) ||...
                        (bestProb.PFP == oldprob.PFP && bestProb.enter > oldprob.enter &&...
                        bestProb.PFP < 0 && oldprob.PFP < 0),
            
            jConfList.add(vM);
            jList.add(bestProb.PFP);
            
            % draw the floor plan image
            image = bestFP.drawImage;
            image = drawFPImageProb(image,bestProb);
            rgb = label2rgb(image,'jet',[.5 .5 .5]);
            imwrite(rgb,[outFolder '/' num2str(cont) '.png'],'PNG');
            cont = cont+1;
            
            % calculate the possible mergings
            allValidMergings = bestFP.calculateAllValidRoomMergingsOfDegree(2);
            fp = bestFP;
        else
            jfpio = javaObject('prog.io.FloorPlanIO');
            jfpio.storeFloorPlan(fp,[outFolder '/' name 'a.java']);
            
            %% now is the moment to consider the possible multiple connections
            % rooms.
            % store the rest of the information
            rooms = fp.getRooms;
            imageRooms = zeros(size(fp.getRegionImage));
            for i=1:size(rooms,1),
                imageRooms(fp.getRegionImage==rooms(i).getId) = 1;
            end
            imwrite(imageRooms,[outFolder 'a.png'],'PNG');
            
            dg = javaObject('prog.matlab.DisconnectedGraphs',fp.getAccessGraph);
            listUG = dg.getListOfDisconnectedGraphhs();
            set = javaObject('java.util.HashSet',listUG);
            
            % create all possible configurations
            ps = javaObject('prog.utils.PowerSet');
            set2 = ps.powerExact(numOfBuildings,set);
            list = javaObject('java.util.ArrayList',set2);
            finalfp = fp.clone;
            for v=0:list.size-1,
                newfp = fp.clone;
                list2 = javaObject('java.util.ArrayList',list.get(v));
                if list2.size == listUG.size,
                    continue;
                end
                for w=0:list2.size-1
                    newfp.eleminateRestOfUnconnectedGraphs(list2.get(w));
                end
                p = calculateFPProbability(newfp,jSTATobj,gmmA,gmmB,likelyhood,gmmC);
                if (p.PFP > oldprob.PFP) ||...
                        (p.PFP == oldprob.PFP && p.enter > oldprob.enter &&...
                        p.PFP < 0 && oldprob.PFP < 0)
                    finalfp = newfp.clone;
                    oldprob = p;
                end
            end
            % draw the floor plan image
            image = finalfp.drawImage;
            image = drawFPImageProb(image,oldprob);
            rgb = label2rgb(image,'jet',[.5 .5 .5]);
            imwrite(rgb,[outFolder '/' num2str(cont) '.png'],'PNG');
            
            % store the rest of the information
            allValidMergings.clear();
            rooms = finalfp.getRooms;
            imageRooms = zeros(size(finalfp.getRegionImage));
            for i=1:size(rooms,1),
                imageRooms(finalfp.getRegionImage==rooms(i).getId) = 1;
            end
            break
        end
    end
    
    
    llista = cell2mat(cell(jList.toArray));
    [~,idx] = sort(llista,'descend');
    image = jFloorPlan.getRegionImage;
    imageFinal = finalfp.getRegionImage;
    save([outFolder '/0results'],'llista','idx','jConfList','image','imageFinal','oldprob','imageRooms');
    imwrite(imageRooms,[outFolder '.png'],'PNG');
    jfpio = javaObject('prog.io.FloorPlanIO');
    jfpio.storeFloorPlan(finalfp,[outFolder '/' name '.java']);
    jSet.clear;
    jList.clear;
    clear jfpio = 0;
    finalfp = 0;
    fp = 0;
    jFloorPlan = 0;
    bestFP =0;
    clearvars -except directoryGT directoryForce jMATreadobj jSTATobj thrs initialFP fnames
end




