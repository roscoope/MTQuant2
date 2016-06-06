%%% calcSplitStats.m
%%% calculate the stats of each split segment of the signal
%%% 
%%% Input arguments 
%%% gLineScanIn = full green signal
%%% rLineScanIn = full red signal
%%% splitSegLen = number of pixels to include in each segment on the neuron
%%% h = single MT brightness calculated using the entire signal
%%% rPeakTol = See MT Quant documentation
%%% toUseRandRPeaks = See MT Quant documentation
%%% rPeakCorr = See MT Quant documentation
%%% toUseHalfMTs = See MT Quant documentation
%%%
%%% Output Arguments
%%% C = Array containing the following parameters for each segment of the neuron:  
%%%      - avg spacing,
%%%      - std dev spacing,
%%%      - single MT brightness, 
%%%      - avg coverage
%%%      - std dev coverage
%%%      - avg length

function C = calcSplitStats(gLineScanIn,rLineScanIn,splitSegLen,h,rPeakTol,toUseRandRPeaks,rPeakCorr,toUseHalfMTs)

lsLen = length(gLineScanIn);
startLocs = 1:splitSegLen:lsLen;
numSegs = length(startLocs);

allSegLens = min(startLocs+splitSegLen,repmat(lsLen,1,numSegs))-startLocs;
startLocs(allSegLens < 10) = [];
numSegs = length(startLocs);

C = zeros(1,numSegs*6);
for i = 1:numSegs
    
    currStart = startLocs(i);
    gLineScan = gLineScanIn(currStart:min(currStart+splitSegLen,lsLen));
    rLineScan = rLineScanIn(currStart:min(currStart+splitSegLen,lsLen));
    
    gHF = gLineScan;
    gHF(gHF<0) = 0;
    rLineScanF = conv(rLineScan,ones(1,3)/3,'same');
    
    [rPeaks,numMTs] = findPeaksWide(rLineScanF,rPeakTol,false,[],toUseRandRPeaks,rPeakCorr);
    
    [meanArrTime,stdArrTime,meanCvg,stdCvg,meanLen] = calcStats(gHF,rPeaks,h,toUseHalfMTs,numMTs);
    
    currStepStats = [meanArrTime,stdArrTime,meanCvg,stdCvg,meanLen];
    currStats1 = [round(h),roundToDec(mean(currStepStats,1),4)];
    currStats = currStats1([2:3,1,4:6]);
    C((6*(i-1)+1):(6*i)) = currStats;
end