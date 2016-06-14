%%% consolidateMTs.m
%%% consolidates a MT matrix to be more densely packed.

function MTblockOut = consolidateMTs(MTblockIn)

MTblockOut = MTblockIn;

for i = 2:size(MTblockIn,1)
    indsNew = find(MTblockOut(i,:));
    for j = 1:i-1
        indsOld = find(MTblockOut(j,:));
        if min(indsNew) > max(indsOld)
            MTblockOut(j,:) = MTblockOut(j,:) | MTblockOut(i,:);
            MTblockOut(i,:) = 0;
            break;
        elseif isempty(indsOld)
            MTblockOut(j,:) = MTblockOut(i,:);
            MTblockOut(i,:) = 0;
            break;
        end
           
    end
end

[r,~] = find(MTblockOut);
MTblockOut = MTblockOut(1:max(r),:);