function floorplanInterpreterSupervised(fitxerInput)

% Floor plan interpreter
% Function to interpret floor plans

%% Run vlfeat

run('E:/Doctorat/FinalFloorPlanInterpretation/2014/vlfeat-0.9.16/toolbox/vl_setup');

%% Load JAVA statistics
directory = 'E:\Doctorat\FinalFloorPlanInterpretation\2013\groundtruth\svg';
jMATreadobj = javaObject('prog.matlab.ReadStatistics',directory);
jSTATobj = jMATreadobj.readFPStatistics;

% vector containing the average area of the rooms vs the areas of
% the plan
jRAPA = double(jSTATobj.roomsAreaVSPlanArea);
% vector from the most little to the biggest room average number of
% rooms
x = min(jRAPA):max(jRAPA)/jSTATobj.avNumberOfRooms:max(jRAPA);
% create and normalize L1 the histogram
[hRAPA,hAxis] = hist(jRAPA,x);
hRAPA = hRAPA/sum(hRAPA);

%% Create output folder
mkdir E:/Doctorat/FinalFloorPlanInterpretation/2014/Results

%% Specify parameters
% this parameters states the minimum certainty to consider a separation a
% wall in the wall detection image.
thrs = 0.30;

%% Program is starting
disp '-> Let´s go!';

%% Create the AND representation from the walls and watershed

% lecture
dircontent=dir(fitxerInput);
fnames=dircontent(3:size(dircontent,1));
clear dircontent;

% op. per a cada imatge
for n=1:size(fnames,1),
    tic
    name = fnames(n).name;
    name = name(1:end-4);
    
    imOriginal = boolean(imread(['E:/Doctorat/FinalFloorPlanInterpretation/2014/Images/' name '.png']));
    imO(:,:) = imOriginal(:,:,1);
    imOriginal = imO;
    if sum(sum(imOriginal==1))>sum(sum(imOriginal==0)),
        imOriginal = ~imOriginal;
    end
    
    
    % create results folder
    outFolder = ['E:/Doctorat/FinalFloorPlanInterpretation/2014/Results/' name];
    mkdir(outFolder);
    
    % crear el Floor Plan
    jFloorPlan = javaObject('prog.strelement.FloorPlan',name);
    
    if ~strcmp(name,'code') && ~strcmp(name,'dades'),
        load([fitxerInput '/' name]);
        % clear impossible walls from the plan at the beginning
        % this is done in function to the size of the pixles when
        % finding walls between parallel lines
        maxpixels = 10;
        imatgeFinal2 = ~finalLabels;
        mwflFinal2 = ~finalLabels;
        
        imatgeFinal2 = imresize(imatgeFinal2,size(imOriginal));
        mwflFinal2 = imresize(mwflFinal2,size(imOriginal));
        
        % clear the hight amount of variables not used in the context
        clearvars -except jSTATobj jFloorPlan fitxerInput imatgeFinal2...
            pixels fnames name jRAPA x hRAPA outFolder imOriginal thrs...
            mwflFinal2 maxpixels cont jList
        
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
        r = regionprops(roomImage,'Area','Centroid','Perimeter','Extrema');
        % the same is done for walls
        r2 = regionprops(logical(wallImage),'Area','FilledImage','Centroid','Perimeter','Extrema','MajorAxisLength');
        % the same is done for walls
        r3 = regionprops(logical(sepImage),'Area','BoundingBox','Image','Centroid','Perimeter','Extrema','MajorAxisLength','MinorAxisLength');
        
        % for each room we add it to the floor plan
        for i=1:length(r),
            room = r(i);
            jRoom = javaObject('prog.strelement.Room',i,room.Area,room.Centroid,room.Perimeter,room.Extrema);
            jFloorPlan.addStructuralElement(jRoom);
        end
        
        % for each wall we add it to the floor plan
        for j=1:length(r2),
            wall = r2(j);
            wThickness = max(max(bwdist(~wall.FilledImage)));
            jWall = javaObject('prog.strelement.Wall',i+j,wall.Area,wall.Centroid,wall.Perimeter,wall.Extrema,wThickness,wall.MajorAxisLength);
            jFloorPlan.addStructuralElement(jWall);
        end
        
        % for each separation we add it to the floor plan
        for n=1:length(r3),
            sep = r3(n);
            porta = hihaporta(sep,1,imOriginal);
            if porta == 0,
                paret = hihaparet(sep,thrs,mwflFinal2,sepImage);
                if paret == 0,
                    jObj = javaObject('prog.strelement.Separation',i+j+n,sep.Area,sep.Centroid,sep.Perimeter,sep.Extrema,sep.MajorAxisLength);
                else
                    jObj = javaObject('prog.strelement.Wall',i+j+n,sep.Area,sep.Centroid,sep.Perimeter,sep.Extrema,sep.MinorAxisLength,sep.MajorAxisLength);
                end
            else
                jObj = javaObject('prog.strelement.Door',i+j+n,sep.Area,sep.Centroid,sep.Perimeter,sep.Extrema,sep.MajorAxisLength);
            end
            jFloorPlan.addStructuralElement(jObj);
        end
        
        %% clean the memory
        
        clearvars -except jFloorPlan jSTATobj hRAPA x fitxerInput imatgeFinal2...
            pixels fnames name outFolder thrs cont jList mwflFinal2
        
        %% Create the graph in java for starting the interpretation
        jFloorPlan.createGraphs();
        
        % first of all, clean those rooms that their area is 0
        jFloorPlan.cleanVerySmallRooms(10);
        
        % secon of all, clean those rooms that are isolated
        jFloorPlan.cleanIsolatedRooms();
        
        % set the classification out for the primitives
        setClassificationScore(jFloorPlan,mwflFinal2);
        
        %% Start the main algorithm
        
        % calculus of the GMM for the model
        %% calcul de GMM
        % GMM sobre les arees de les habitacions
        Ka = 10;
        arees = sort(double(jSTATobj.roomsAreas));
        gmmA = gmdistribution.fit(arees,Ka);
        
        % GMM sobre la longitud dels elements
        Kw = 50;
        Kd = 10;
        Ks = 5;
        lWalls = double(jSTATobj.lWalls);
        lDoors = double(jSTATobj.lDoors);
        lSep = double(jSTATobj.lSep);
%         gmmW = gmdistribution.fit(lWalls,Kw,'Regularize',1e-10);
%         gmmD = gmdistribution.fit(lDoors,Kd,'Regularize',1e-10);
%         gmmS = gmdistribution.fit(lSep,Ks,'Regularize',1e-10);
        
        % likelihood learning
        X = double(jSTATobj.likelyhoodX);
        Y = double(jSTATobj.likelyhoodY);
        likelyhood = mnrfit(X,Y);
        
        % calculate the probability of the floor plan in the actual state.
        % This is P(B)*P(B|R-R)*P(R)*P(R|W--S), where:
        % P(B) is the area of the plan given the areas
        % P(B|R) is the distribution of the area of the rooms
        % P(R) is the area of the room in the distribution
        % P(R|W-S) is the potential function.
        cont = 1;
        jList = java.util.ArrayList;
        jConfList = java.util.ArrayList;
        bestProb = calculateFPProbability(jFloorPlan,jSTATobj,gmmA,likelyhood);
        jList.add(bestProb.PFP);
        
        % store the rooms ids for this plan
        jConfList.add([]);
        
%         image = jFloorPlan.drawImage;
%         image = drawFPImageProb(image,bestProb);
%         rgb = label2rgb(image,'jet',[.5 .5 .5]);
%         imwrite(rgb,[outFolder '/' num2str(cont) '.png'],'PNG');
        %cont = cont+1;
        
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
            %fp = clone(newFP);
            PFPAnt = bestProb.PFP;
            oldfp = fp.clone;
            oldprob = bestProb;
            %             listOfFP = java.util.ArrayList;
            %             listOfProbs = [];
            bestProb=[];
            
            % bar things
            h = waitbar(0,'Please wait...');
            barstate = 0;
            barsteps = allValidMergings.size;
            for j=0:allValidMergings.size-1;
                validMerging = allValidMergings.get(j);
                %                 if (~jSet.contains(validMerging)),
                % get the Ids of the rest of the rooms that are not merged
                restOfRooms = fp.clone.getRestOfRoomsIds(validMerging);
                % get the minimum idx of the rooms to merge
                minRoomMergingIdx =  min(cell2mat(cell(validMerging.toArray)));
                % get the final configuration of the rooms
                restOfRooms.add(uint32(minRoomMergingIdx));
                % calculate the floor plan configuration
                newFP = newFloorPlanComposition(fp.clone,validMerging);
                % store the fp in the list of FP
                %                 listOfFP.add(newFP);
                % calculate the new probability
                [p] = calculateFPProbability(newFP,jSTATobj,gmmA,likelyhood);
                % cat the probability for the floor plan
                %                 listOfProbs = cat(1,listOfProbs,p);
                %                 end
                if isempty(bestProb),
                    bestProb = p;
                    bestFP = newFP.clone;
                    vM = validMerging;
                elseif  p.PFP > bestProb.PFP
                    bestProb = p;
                    bestFP = newFP.clone;
                    vM = validMerging;
                end
                waitbar(barstate / barsteps)
                barstate = barstate+1;
            end
            close(h);
            if(oldprob.PFP < bestProb.PFP),
                
                jConfList.add(vM);
                jList.add(bestProb.PFP);
                
                % draw the floor plan image
                %image = bestFP.drawImage;
                %image = drawFPImageProb(image,bestProb);
                %rgb = label2rgb(image,'jet',[.5 .5 .5]);
                %imwrite(rgb,[outFolder '/' num2str(cont) '.png'],'PNG');
                %cont = cont+1;
                
                % calculate the possible mergings
                allValidMergings = bestFP.calculateAllValidRoomMergingsOfDegree(2);
%                 rooms = bestFP.getRooms;
%                 imageRooms = zeros(size(bestFP.getRegionImage));
%                 for i=1:size(rooms,1),
%                     imageRooms(bestFP.getRegionImage==rooms(i).getId) = 1;
%                 end
                fp = bestFP;
            else
                allValidMergings.clear();
                rooms = fp.getRooms;
                imageRooms = zeros(size(fp.getRegionImage));
                for i=1:size(rooms,1),
                    imageRooms(fp.getRegionImage==rooms(i).getId) = 1;
                end
                break
            end
        end
        
    end
    llista = cell2mat(cell(jList.toArray));
    [~,idx] = sort(llista,'descend');
    image = jFloorPlan.getRegionImage;
    imageFinal = fp.getRegionImage;
    save([outFolder '/0results'],'llista','idx','jConfList','image','imageFinal','oldprob','imageRooms');
    imwrite(imageRooms,[outFolder '.png'],'PNG');
    jfpio = javaObject('prog.io.FloorPlanIO');
    jfpio.storeFloorPlan(fp,[outFolder '/' name '.java']);
    jSet.clear;
    jList.clear;
    toc
end




