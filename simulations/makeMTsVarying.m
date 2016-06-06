%%% makeMTsVarying.m
%%% Generate random MTs
%%%
%%% Input Arguments
%%% sigLenIn = length of signal to simulate MTs for
%%% whichDist = selects the distribution from which to draw the MT minus-ends.  When
%%%      0, this draws from our data's distribution.  If set to 1, it uses an exponential
%%%      distribution instead
%%% spcFactor = Factor by which to multiply the randomly drawn spacing of each
%%%      MT.  By default, set this input to 1. To increase coverage, set this input
%%%      to something less than 1
%%% lenFactor = Factor by which to multiply the randomly drawn length of each
%%%      MT.  By default, set this input to 1. To increase coverage, set this input
%%%      to something greater than 1
%%%
%%% Output Arguments
%%% MTmodel = matrix of randomly generated MTs.  The matrix dimensions are N X lsLen,
%%%       where N is the number of randomly generated MTs.  Each row of this matrix is
%%%       a binary indicator of the MT's prescence, i.e. row 5 of MTmodel
%%%       is 0 everywhere except the portion of the line scan in which the fifth
%%%       generated MT exists
%%% arrs = vector of randomly generated MT minus-end locations

function [MTmodel,arrs] = makeMTsVarying(sigLenIn,whichDist,spcFactor,lenFactor)

%%% extend the signal so that all MTs don't arbitrarily start at pixel 1
sigLen = sigLenIn + 100;

%%% Generate the MT minus-ends
if ~whichDist
    load('allSpc2XMedian.mat');
    lambda = 10.2788; %%% Parameter generated assuming that the data from
    %%% allSpc2XMedian.mat is distributed with a Poisson distribution
end
arrs = 1;
while (max(arrs) < sigLen)
    if whichDist ==1
        nextMT = exprnd(7*spcFactor);
    else
        allSpc(allSpc > 100) = [];
        randInd = randi(length(allSpc));
        nextMT = allSpc(randInd)*spcFactor;
    end
    arrs = [arrs max(arrs)+nextMT];
end
arrs = round(arrs);

%%% Initialize the output MTmodel
MTmodel = zeros(length(arrs),sigLen);

%%% Generate the random MT lengths based on the Baas MT lenght distribution
%%% First select an average length for the entire signal, and then scale
%%% the Baas distribution to have that mean
muMeanL = 32;
sigmaMeanL = 7;
meanL = normrnd(muMeanL,sigmaMeanL);
maxL = 60;
sf = meanL / 20;
x = [0 5 10 15 20 25 30]*sf;
y = [960, 210, 110, 50, 20, 10, 3];
f = fit(x',y','exp1');
xx = 0:0.1:50;
yy = feval(f,xx);
baasPdf = yy/sum(yy);
baasCdf = cumsum(baasPdf);

for i = 1:length(arrs)
    if arrs(i) < sigLen
        mtLen = xx(find(rand>baasCdf,1,'last'))/0.17 *lenFactor ;
        mtLen = round(mtLen);
        if mtLen < 1
            mtLen = 1;
        elseif mtLen > maxL
            mtLen = maxL;
        end
        MTmodel(i,arrs(i):min(sigLen,arrs(i)+mtLen)) = 1;
    end
end

%%% Trim the signal to fit the input sigLenIn and remove any MTs whose
%%% generated length was 0
MTmodel = MTmodel(:,101:end);
MTmodel(all(MTmodel==0,2),:)=[];