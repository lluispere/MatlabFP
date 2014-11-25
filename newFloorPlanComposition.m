function [newFP,p] = newFloorPlanComposition(fp,rooms2mergeIds,jSTATobj,gmmA,gmmB,likelyhood)

fp1 = fp.clone;
fp2 = fp.clone;
% change the type of primitive into consideration
changed = fp1.changePrimitiveClass(rooms2mergeIds);
% get the probability
%if changed == false
    %p1.PFP = 0;
%else 
p1 = calculateFPProbability(fp1,jSTATobj,gmmA,gmmB,likelyhood);
%end
% calculate the new image of the plan after the merging
[imageRoom,imagePlan] = updateImage(fp2,rooms2mergeIds);

% merge the rooms in the plan graphs
[fp2] = merge2Rooms(fp2,rooms2mergeIds,imageRoom,imagePlan);

% get the probability
p2 = calculateFPProbability(fp2,jSTATobj,gmmA,gmmB,likelyhood);

% return that plan with the highest probability
if p2.PFP > p1.PFP || (p2.PFP == p1.PFP && p2.enter > p1.enter &&...
                        p2.PFP < 0 && p1.PFP < 0),
    newFP = fp2;
    p = p2;
else newFP = fp1;
    p = p1;
end
