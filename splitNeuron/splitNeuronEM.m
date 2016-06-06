%%% splitNeuronEM.m
%%% This function applies distribution-refinement to each group of the data
%%% in a split file
%%%
%%% Input Arguments
%%% statsFile = the name of a '* split.csv' of a '* splitComm.csv' output file gen-
%%%      erated by splitNeuron or splitAxonComm
%%% 
%%% Output Arguments
%%% fileOut = name of output file containing split information. Same as statsFile, but with string
%%%      '_em' appended to it. First three columns of the output file are same as 
%%%      the first three columns of statsFile. The remaining columns are the average spacing, 
%%%      std dev of spacing, single MT brightness, average coverage, std dev of coverage, 
%%%      and average length for each segment. The column names are the same as in statsFile, 
%%%      but with 'S* ' prepended to each, where the askterisk (*) is the segment number. The
%%%      segment number 1 refers to the segment with the green star in Figure 1 in the MTQuant documentation.

function fileOut = splitNeuronEM(statsFile)

T = readtable(statsFile);
varNames = T.Properties.VariableNames;
[folder,name,ext] = fileparts(statsFile);
fileOut = [folder,'\',name,'_em',ext];

data = table2cell(T);
dirNums = cell2mat(data(:,3));
uDirNums = unique(dirNums);

emSplitC = data;
numSegs = (size(data,2)-3)/6;
dirsToCompare = uDirNums;
for j = 1:length(dirsToCompare)
    testDir = dirsToCompare(j);
    for i = 1:numSegs
        startInd = (i-1)*6+4;
        currWorms = find(dirNums==testDir);
        oldS = cell2mat(data(currWorms,startInd+1));
        oldC = cell2mat(data(currWorms,startInd+3));
        oldL = cell2mat(data(currWorms,startInd+5));
        oldH = cell2mat(data(currWorms,startInd));
        sspcV = cell2mat(data(currWorms,startInd+2));
        scvgV = cell2mat(data(currWorms,startInd+4));
        toRemove = oldS==0 | isnan(oldS) | sspcV==0 | isnan(sspcV) | oldC==0 | isnan(oldC) | scvgV==0 | isnan(scvgV) | oldL==0 | isnan(oldL) | oldH==0 | isnan(oldH);
        oldS(toRemove) = [];
        oldC(toRemove) = [];
        oldL(toRemove) = [];
        oldH(toRemove) = [];
        currWorms(toRemove) = [];
        thresh = 0.01;
        if length(currWorms) > 1
            [piL,muL,sigmaL,Ls,newL] = emLoop1Var(oldL(:),thresh);
            [piS,muS,sigmaS,Ss,newMeanS] = emLoop1Var(oldS(:),thresh);
            [piH,muH,sigmaH,Hs,newH] = emLoop1Var(oldH(:),thresh);
            [piC,muC,sigmaC,Cs,newC] = emLoop1Var(oldC(:),thresh);
            emSplitC(currWorms,startInd+1)=num2cell(newMeanS);
            emSplitC(currWorms,startInd+0)=num2cell(newH);
            emSplitC(currWorms,startInd+3)=num2cell(newC);
            emSplitC(currWorms,startInd+5)=num2cell(newL);
        end
    end
end
Tout = cell2table(emSplitC,'variablenames',varNames);
writetable(Tout,fileOut);
