%%% getFolderNamesFromTable.m
%%% This function takes a list of directory names (the first output column
%%% of an MTQuant output .CSV file), and the integer dirNums (the third
%%% output column of an MTQuant output .CSV file)
%%%
%%% Input arguments
%%% directories = first output column of an MTQuant output .CSV file
%%% dirNums = third output column of an MTQuant output .CSV file
%%%
%%% Output arguments
%%% folderNames = unique folder names of all of the data
%%% allDescs = folder names for each of the rows in the MTQuant output .CSV file
%%% uDirNums = unique dirNums corresponding to folderNames

function [folderNames,allDescs,uDirNums] = getFolderNamesFromTable(directories,dirNums)

allDescs = cell(size(directories));
for i = 1:length(directories)
    f = directories{i};
    [str,remain] = strtok(f,'\');
    while (isempty(strfind(str,'L')) && ~isempty(remain)) && (isempty(strfind(str,'dauer')) && ~isempty(remain))
        [str,remain] = strtok(remain,'\');
    end
    allDescs(i) = {str};
end
[folderNames,inds] = unique(allDescs,'stable');
    
uDirNums = dirNums(inds);