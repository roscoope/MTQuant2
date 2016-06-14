%%% visualizeMTs
%%% Plots two types of visualizations:  one is a tall visualization and
%%% the other one consolidates the MTs to be more densely packed.
%%%
%%% Input Arguments
%%% qScan = quantized line scan
%%% MTblock = matrix of MTs.  The matrix dimensions are N X lsLen,
%%%       where N is the total number of MTs.  Each row of this matrix is
%%%       a binary indicator of the MT's prescence, i.e. row 5 of MTblock
%%%       is 0 everywhere except the portion of the line scan in which the fifth
%%%       generated MT exists
%%% fileName = base filename to which the visualiztion images will be saved
%%%
%%% Output arguments
%%% h1, h2 = handles to figures created in this function
%%%
%%% Output Files (generated in visualizeMTs.m)
%%% *_visualization1.bmp and *_visualization2.bmp = plots of two types of
%%%      visualizations for each file in filesToPrint

function [h1,h2] = visualizeMTs(qScan,MTblock,fileName)

mtLengths = sum(MTblock,2);
meanLength = sum(qScan) / size(MTblock,1);
meanCvg = mean(qScan);

h1 = figure;
title(horzcat('MT Visualization, ', num2str(length(mtLengths)),' MTs, Mean Length = ',num2str(meanLength),' pixels, Mean Coverage = ',num2str(meanCvg),' MTs/pixel'));
for i = 1:size(MTblock,1)
    hold on;
    plot([find(MTblock(i,:),1,'first') find(MTblock(i,:),1,'last')],[i i],'.-','LineWidth',2,'MarkerSize',10,'color',[0 .5 0]);
end
axis([0 1000 0 100]);
xlabel('pixels')

MTblock2 = consolidateMTs(MTblock);
maxCvg = max(sum(MTblock2));
h2 = figure;
position = get(h2,'Position');
set(h2,'Position',[position(1:3) position(4)/3]);
title(horzcat('MT Visualization, ', num2str(length(mtLengths)),' MTs, Mean Length = ',num2str(meanLength),' pixels, Mean Coverage = ',num2str(meanCvg),' MTs/pixel'));
for i = 1:size(MTblock2,1)
    hold on;
    stats = regionprops(logical(MTblock2(i,:)),'PixelIdxList');
    for j = 1:length(stats)
        currInds = stats(j).PixelIdxList;
        plot(([min(currInds) max(currInds)]),[i i],'LineWidth',5,'color',[0 .5 0]);
    end
end
axis([0 (length(qScan)+10) 0 maxCvg+1]);
xlabel('pixels')

print(h1,strcat(fileName,'1'),'-dbitmap');
print(h2,strcat(fileName,'2'),'-dbitmap');
