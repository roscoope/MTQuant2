%%% runModel.m
%%% Runs the model
%%%
%%% Input Arguments
%%% numRuns = number of simulations to do at once
%%% spcFactor = Factor by which to multiply the randomly drawn spacing of each
%%%      MT.  By default, set this input to 1. To increase coverage, set this input
%%%      to something less than 1
%%% lenFactor = Factor by which to multiply the randomly drawn length of each
%%%      MT.  By default, set this input to 1. To increase coverage, set this input
%%%      to something greater than 1
%%% MTQuantArgs = cell array of name-value pairs as would be send to
%%%      MTQuant (see MTQuant documentation for possible arguments)
%%%
%%% Output Arguments
%%% modelB = random single MT brightness generated in model
%%% modelS = average random spacing generated in model
%%% modelC = average coverage of MTs generated in model
%%% modelL = average length of MTs generated in model
%%% calcB = single MT brightness calculated for random MTs
%%% calcS = average spacing calculated for random MTs
%%% calcC = average coverage calculated for random MTs
%%% calcL = average length calculated for random MTs

function [modelB,modelS,modelC,modelL,calcB,calcS,calcC,calcL] = runModel(numRuns,spcFactor,lenFactor,MTQuantArgs)

N = numRuns;

%%% Generate line scans
[~,~,Pnn,~] = getNoiseProfile;
segLen = 21;
Snn = segLen * abs([Pnn',Pnn(end-1:-1:2)']);
muPsf = 0;
sigmaPsf = 1.27; % equivalent to real avg PSF
psf = gaussmf(-10:10,[sigmaPsf muPsf]);
psf = psf/sum(psf);

mkdir('simTempDir');
modelB = zeros(N,1);
modelL = zeros(N,1);
modelC = zeros(N,1);
modelS = zeros(N,1);
for i = 1:N
    [gSignalClean,gNoise,rSignalClean,rNoise,upLocs,downLocs,bModel,MTmodel] = genScans(500,Snn,spcFactor,lenFactor);
    
    gLineScan = conv(gSignalClean,psf,'same') + 2000+ gNoise/2;
    rLineScan =  conv(rSignalClean,psf,'same') + 2000+rNoise/2;
    
    scansIn = [gLineScan,rLineScan];
    scansIn(scansIn < 0) = 0;
    csvwrite(['simTempDir\',num2str(i),'_LineScans.csv'],scansIn);
    
    modelS(i) = mean(diff(upLocs));
    modelB(i) = bModel;
    modelC(i) = mean(sum(MTmodel,1));
    modelL(i) = mean(sum(MTmodel,2));
end

%%% Analyze the line scans using MTQuant
commandStr = [];
if exist('MTQuantArgs','var') && ~isempty(MTQuantArgs)
    for i = 1:2:length(MTQuantArgs)
        currStr = MTQuantArgs{i};
        commandStr = [commandStr, ', ''',currStr,''''];
        currVal = MTQuantArgs{i+1};
        if ~ischar(currVal)
            currVal = num2str(currVal);
        end
        commandStr = [commandStr, ', ',currVal];
    end
end
eval(['MTQuant({''simTempDir''},''simTempDir\tempData'',''taskList'',8',commandStr,')']);

%%% Get data to output from this function
T = readtable('simTempDir\tempData_2.csv');
varNames = T.Properties.VariableNames;
BInd = find(strcmp('Single_MT_Brightness',varNames));
SInd = find(strcmp('Avg_Spacing',varNames));
CInd = find(strcmp('Avg_Coverage',varNames));
LInd = find(strcmp('Avg_Length',varNames));

C = table2cell(T);
calcB = cell2mat(C(:,BInd));
calcL = cell2mat(C(:,LInd));
calcC = cell2mat(C(:,CInd));
calcS = cell2mat(C(:,SInd));

%%% Try to delete all of the directories/files that were generated in this function
delete('simTempDir\*.csv');
try
    rmdir('simTempDir','s');
catch err
    display('The temp directory "simTempDir" was not successfully removed; feel free to delete it (and its contents) yourself');
end