%%% pairMTs
%%% Pairs MT starts with MT ends to use for visualizing the MT organization
%%% in an animal.
%%%
%%% Input Arguments
%%% qScan = quantized line scan
%%% numMTs = number of microtubules in the scan
%%% pairMode = 0 to pair MT ends with MT start that generates
%%%      the longest MT, 1 to pair MT ends with MT start that generates shortest
%%%      MT, and 2 to pair MT ends with a random MT start.
%%%
%%% Output arguments
%%% starts = list of MT starting locations
%%% ends = list of MT ending locations
%%% MTblock = matrix of MTs.  The matrix dimensions are N X lsLen,
%%%       where N is the total number of MTs.  Each row of this matrix is
%%%       a binary indicator of the MT's prescence, i.e. row 5 of MTblock
%%%       is 0 everywhere except the portion of the line scan in which the fifth
%%%       generated MT exists

function [starts,ends,MTblock] = pairMTs(qScan,numMTs,pairMode)

qDiff = diff(qScan);
stepsUp = find(qDiff>0);
multUps = find(qDiff>1);
for i = 1:length(multUps)
    stepsUp = [stepsUp; multUps(i)*ones(qDiff(i),1)];
end
stepsDown = find(qDiff<0);
multDowns = find(qDiff<-1);
for i = 1:length(multDowns)
    stepsDown = [stepsDown; multDowns(i)*ones(qDiff(i),1)];
end

%%% Add some steps up to compensate for those that are blurred by steps down, based on the total number of MTs
numToAdd = numMTs - length(stepsUp);
if numToAdd > 0
    randInds = randperm(length(stepsUp),numToAdd);
    newStepsUp = stepsUp(min(randInds,length(stepsUp)));
    stepsUp = sort([stepsUp;newStepsUp]);
    stepsDown = sort([stepsDown;newStepsUp]);
end

unusedUpLocs = [zeros(qScan(1),1); stepsUp];
MTblock = zeros(length(unusedUpLocs),length(qScan));
for i = 1:size(MTblock,1)
    MTblock(i,unusedUpLocs(i)+1:end) = 1;
end

stepsDown(stepsDown<min(unusedUpLocs)) = [];

starts = [];
ends = [];
for i = 1:length(stepsDown)
    switch(pairMode)
        case 0 % longest
            ind = find(MTblock(:,stepsDown(i)) & MTblock(:,end),1,'first');
        case 1 % shortest
            ind = find(MTblock(:,stepsDown(i)) & MTblock(:,end),1,'last');
        case 2 % random
            inds = find(MTblock(:,stepsDown(i)) & MTblock(:,end));
            if ~isempty(inds)
                randInd = randi(length(inds));
                p = 0.5;
                randInd = min(geornd(p)+1,length(inds));
                ind = inds(randInd);
            end
    end
    MTblock(ind,stepsDown(i)+1:end) = 0;
    starts = [starts;unusedUpLocs(ind)];
    ends = [ends;stepsDown(i)];
end

