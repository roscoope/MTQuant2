%%% makeModelEmpNoise.m
%%% Generate clean signals and noise for both red and green channels based
%%% on the MTmodel
%%%
%%% Input Arguments
%%% MTmodel = matrix of randomly generated MTs.  The matrix dimensions are N X lsLen,
%%%       where N is the number of randomly generated MTs.  Each row of this matrix is
%%%       a binary indicator of the MT's prescence, i.e. row 5 of MTmodel
%%%       is 0 everywhere except the portion of the line scan in which the fifth
%%%       generated MT exists
%%% Snn = PSD of measured noise
%%% bModel = randomly drawn single MT brightness
%%%
%%% Ouptut Arguments
%%% gSignalClean = (quantized) green signal before any blurring or additive noise
%%% gNoise = randomly generated noise to add to the green signal
%%% rSignalClean = red signal before any blurring or additive noise
%%% rNoise = randomly generated noise to add to the red signal

function [gSignalClean,gNoise,rSignalClean,rNoise] = makeModelEmpNoise(MTmodel,Snn,bModel)

%%% Generate the clean green signal
signalIn1 = sum(MTmodel,1);
gSignalClean = (signalIn1')*bModel;

lsLen = length(gSignalClean);

%%% Generate the clean red signal
%%% Find the starting locations of each MT in the model
N = size(MTmodel,1);
rLocs = zeros(N,1);
for i = 1:N
    nextLoc = find(MTmodel(i,:),1,'first');
    rLocs(i) = nextLoc;
end
%%% Decide if any of the MT minus-ends should be ignored to simulate
%%% low penetrance of patronin.  pRed can be decreased from 1, but by
%%% default we assume red patronin binds to all MT minus ends.
pRed = 1;
rLocs = rLocs(logical(binornd(1,pRed,1,length(rLocs))));
%%% Adjust the patronin signal since we don't know how patronin really
%%% binds to MT minus ends.  For each location, adjust its height and width.
randHeight = 1; %%% Change this to use a uniform height for every patronin peak
randWidth = 1; %%% Change this to use a delta function for every patronin peak
if randHeight
    rHeights = 1+rand(size(rLocs));
else
    rHeights = ones(size(rLocs));
end
pRedToExtend = rand(1);
rSignalClean = zeros(lsLen,1);
for i = 1:length(rLocs)
    if  randWidth && binornd(1,pRedToExtend)
        locsToAdd = randi([0,5],1);
        startLoc = rLocs(i);
        endLoc = min(rLocs(i)+1+locsToAdd,lsLen);
        rSignalClean(startLoc:endLoc) = rSignalClean(startLoc:endLoc) + rHeights(i);
    else
        rSignalClean(rLocs(i)) = rSignalClean(rLocs(i)) + rHeights(i);
    end
end
rSignalClean = rSignalClean * bModel/10;

%%% Generate the noise for both signals
gNoise1 = imageNoise(lsLen,Snn);
gNoise2 = linRescale(gNoise1)*bModel*0.2;
gNoise3 = gNoise2 - mean(gNoise2(:));
gNoise = gNoise3*10;
%gNoise = 10*sqrt(max(signalOut))*gNoise1/(max(gNoise1)+1);

rNoise1 = imageNoise(lsLen,Snn);
rNoise2 = linRescale(rNoise1)*bModel*0.2;
rNoise3 = rNoise2 - mean(rNoise2(:));
rNoise = rNoise3/2;
%rNoise = sqrt(max(rSignalOut))*rNoise1/(max(rNoise1)+1);


