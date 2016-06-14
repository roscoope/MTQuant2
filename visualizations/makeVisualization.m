%%% makeVisualization.m
%%% Generates MT visualizations for a list of line scan files
%%%
%%% Input Arguments
%%% filesToPrint = cell string array of *LineScans.csv files to visualize
%%% brightnessArray = array of single MT brightnesses corresponding to the
%%%      files in filesToPrint.  Expected to be the same length as the array
%%%      filesToPrint.
%%% numMTArray = array of extracted number of MTs for each file in filesToPrint
%%%      Expected to be the same length as the array filesToPrint.
%%% roundLevel (optional) = level at which to round the green line scan up or down
%%%      (default is 0.5, i.e. normal rounding) when calculating the quantized
%%%      signal
%%% pairMode (optional) = 0 to pair MT ends with MT start that generates
%%%      the longest MT, 1 to pair MT ends with MT start that generates shortest
%%%      MT, and 2 to pair MT ends with a random MT start.
%%%
%%% Output Files (generated in visualizeMTs.m)
%%% *_visualization1.bmp and *_visualization2.bmp = plots of two types of
%%%      visualizations for each file in filesToPrint

function makeVisualization(filesToPrint,brightnessArray,numMTArray,roundLevel,pairMode)

if ~exist('roundLevel','var')
    roundLevel = 0.5;
end
if ~exist('pairMode','var')
    pairMode = 0;
end

for i = 1:length(filesToPrint)
    currFile = filesToPrint{i};
    currB = brightnessArray(i);
    numMTs = numMTArray(i);
    
    [folder,name,~] = fileparts(currFile);
    scansIn = csvread(currFile);
    
    g = scansIn(:,1);
    remScan = mod(g,currB);
    ceilInds = remScan >= currB*roundLevel;
    floorInds = remScan < currB*roundLevel;
    qScan = zeros(size(g));
    qScan(ceilInds) = ceil(g(ceilInds)/currB);
    qScan(floorInds) = floor(g(floorInds)/currB);
    [~,~,MTblock] = pairMTs(qScan,numMTs,pairMode);
    fileOut = [folder,'\',name,'_visualization'];
    [h1,h2] = visualizeMTs(qScan,MTblock,fileOut);
    set(h1,'name',currFile);
    set(h2,'name',currFile);
end