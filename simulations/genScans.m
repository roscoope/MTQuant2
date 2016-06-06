%%% getScans.m
%%% This function is the wrapper file that generates the simulated MTs.
%%%
%%% Input Arguments
%%% lsLen = length of line scan to simulate
%%% Snn (optional) = PSD of observed noise (leave this empty unless you
%%%      want to change the noise)
%%% spcFactor (optional) = Factor by which to multiply the randomly drawn
%%%      spacing of each MT.  By default, this input is 1. To increase coverage,
%%%      set this input to something less than 1
%%% lenFactor (optional) = Factor by which to multiply the randomly drawn
%%%      length of each MT.  By default, this input is 1. To increase coverage,
%%%      set this input to something greater than 1
%%%
%%% Output Arguments
%%% gSignalClean = (quantized) green signal before any blurring or additive noise
%%% gNoise = randomly generated noise to add to the green signal
%%% rSignalClean = red signal before any blurring or additive noise
%%% rNoise = randomly generated noise to add to the red signal
%%% uplocs = vector of pixel starting locations of each randomly generated MT
%%% downlocs = vector of pixel ending locations of each randomly generated MT
%%% bModel = randomly drawn single MT brightness
%%% MTmodel = matrix of randomly generated MTs.  The matrix dimensions are N X lsLen,
%%%       where N is the number of randomly generated MTs.  Each row of this matrix is
%%%       a binary indicator of the MT's prescence, i.e. row 5 of MTmodel
%%%       is 0 everywhere except the portion of the line scan in which the fifth
%%%       generated MT exists

function [gSignalClean,gNoise,rSignalClean,rNoise,upLocs,downLocs,bModel,MTmodel] = genScans(lsLen,Snn,spcFactor,lenFactor)

%%% Set scaling factor defaults
if ~exist('spcFactor','var')
    spcFactor = 1;
end
if ~exist('lenFactor','var')
    lenFactor = 1;
end

%%% Generate the noise PSD by referencing fluorescence bead images
segLen = 21;
if ~exist('Snn','var') || isempty(Snn)
    [Snn,Rnn,Pnn,mpAll] = getNoiseProfile;
    Snn = segLen * abs([Pnn',Pnn(end-1:-1:2)']);
end

%%% Generate the MTs
whichDist = 1; %%% change this to 1 to use an exponential distribution instead of our data's distribution
MTmodel = makeMTsVarying(lsLen,whichDist,spcFactor,lenFactor);

%%% Randomly select the single MT brightness.  Make sure the brightnes is not negative
bModel = -1;
while bModel <= 0
    bModel = normrnd(2e4,8e3);
end

%%% Generate the line scans and the noise.  Make sure the noise isn't too
%%% high in magnitude.
gSNR = 0;
rSNR = 0;
while (gSNR < 5 || rSNR < 0.05)
    [gSignalClean,gNoise,rSignalClean,rNoise] = makeModelEmpNoise(MTmodel,Snn,bModel);
    gSNR = mean(gSignalClean) / std(gNoise);
    rSNR = mean(rSignalClean) / std(rNoise);
end

%%% Calculate upLocs and downLocs
upLocs = [];
for i = 1:size(MTmodel,1)
    upLocs = [upLocs; find(MTmodel(i,:),1,'first')];
end
downLocs = [];
for i = 1:size(MTmodel,1)
    downLocs = [downLocs; find(MTmodel(i,:),1,'last')];
end

