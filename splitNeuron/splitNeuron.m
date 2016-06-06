%%% splitNeuron
%%% Splits the axon and generates the organization parameters for each
%%% segment of the neuron
%%%
%%% Input Arguments
%%% statsFile = Output CSV file from MTQuant containing the neuron-wide
%%%      organization parameters for the worms to be split
%%% splitSegLen = number of pixels to include in each segment on the neuron
%%% groups (optional) = list of group numbers to compare. These are the values of the DirNum
%%%      column of the output file. If groups is not inputted, or it is empty (i.e. 
%%%      groups=[];), the function compares all groups.
%%% toUseRandRPeaks (optional) = if true (default), additional MT minus-ends
%%%      beyond the peaks in the red line scan are chosen randomly for increased
%%%      accuracy.
%%% rPeakTol (optional) = tolerance of peak selection.  This value is multiplied
%%%      by the maximum value of rLineScanF.  For a peak to be considered real
%%%      (and not noise), the difference between the peak and the nearest valley
%%%      must be at least tol*max(rLineScanF).  A higher value for tol means
%%%      fewer peaks are identified.  By default, tol = 0.01.
%%% rPeakCorr (optional) = Weight on Bernouli random variable that decides if a single 
%%%      red dot is 1 or 2 MT minus-ends. As coverage increases, this value 
%%%      should increase as well (up to 20 if necessary)
%%% toUseHalfMTs (optional) = correction for the beginning and end of the signal 
%%%      Makes very inconsequential changes; can be ignored
%%% 
%%% Output Arguments
%%% fileOut = name of output file containing split information. Same as statsFile, but with string
%%%      '_splitComm' appended to it. First three columns of the output file are same as 
%%%      the first three columns of statsFile. The remaining columns are the average spacing, 
%%%      std dev of spacing, single MT brightness, average coverage, std dev of coverage, 
%%%      and average length for each segment. The column names are the same as in statsFile, 
%%%      but with 'S* ' prepended to each, where the askterisk (*) is the segment number. The
%%%      segment number 1 refers to the segment with the green star in Figure 1 in the MTQuant documentation.

function fileOut = splitNeuron(varargin)

nargin = length(varargin);
if nargin < 2
    error('Error:  Not enough input arguments.');
elseif mod(nargin,2) == 1
    error('Error:  Mismatched input arguments.');
end

statsFile = varargin{1};
splitSegLen = varargin{2};

rPeakTol = 0.05;
toUseRandRPeaks = 1;
rPeakCorr = 0.1;
toUseHalfMTs = 0;

for i = 3:2:nargin
    currStr = varargin{i};
    currVal = varargin{i+1};
    eval([currStr,' = currVal;']);
end

[folder,name,ext] = fileparts(statsFile);
fileOut = [folder,'\',name,'_split',ext];

T = readtable(statsFile);
C = table2cell(T);

fileNamesAll = cellfun(@(x,y) strcat(x,'\',y),C(:,1),C(:,2),'uniformoutput',false);
dirNumsAll = cell2mat(C(:,3));
uDirNums = unique(dirNumsAll);

[uFolderNames,~,~] = getFolderNamesFromTable(C(:,1),dirNumsAll);
varNames = T.Properties.VariableNames;
HInd = find(strcmp('Single_MT_Brightness',varNames));

if ~exist('groups','var') || isempty(groups)
    groups = uDirNums;
end

if iscellstr(groups)
    dirsToCompare = find(ismember(uFolderNames,groups));
else
    dirsToCompare = groups;
end

dirLocs = ismember(dirNumsAll,dirsToCompare);
fileNames = fileNamesAll(dirLocs);
Hs = cell2mat(C(dirLocs,HInd));

dataC = [];
for count = 1:length(fileNames)
    dataFile = fileNames{count};  % Line Scan file
    scansIn = csvread(dataFile);
    gLineScan = scansIn(:,1);
    rLineScan = scansIn(:,2);
    currC = calcSplitStats(gLineScan,rLineScan,round(splitSegLen),Hs(count),rPeakTol,toUseRandRPeaks,rPeakCorr,toUseHalfMTs);
    if isempty(dataC)
        dataC = zeros(length(fileNames),length(currC));
    end
    if length(currC) > size(dataC,2)
        dataC = [dataC zeros(length(fileNames),length(currC)-size(dataC,2))];
    end
    dataC(count,1:length(currC)) = currC;
end

Cout = [C(dirLocs,1:3), num2cell(dataC)];
segVarNames = arrayfun(@(x) strcat('S',num2str(x),'_',varNames(end-5:end)),1:size(dataC,2)/6,'uniformoutput',false);
varNamesOut = varNames(1:3);
for i = 1:length(segVarNames)
    varNamesOut = [varNamesOut, segVarNames{i}];
end
Tout = cell2table(Cout,'VariableNames',varNamesOut);
writetable(Tout,fileOut);
