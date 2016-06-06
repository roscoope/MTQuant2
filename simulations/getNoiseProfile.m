%%% getNoiseProfile
%%% Get the noise periodogram/PSD from images of fluorescent beads

function [Snn,Rnn,Pnn,mpAll,f] = getNoiseProfile

stackFile = 'beads_10-23-2014_1 60X_02.TIF';
[~, ~, mp, ~] = readStackSingle(stackFile);
mpAll = [mp(1:230,:);mp(300:end,:)];

stackFile = 'beads_10-23-2014_2 60X_02.TIF';
[~, ~, mp, ~] = readStackSingle(stackFile);
mpAll = [mpAll; mp(1:290,:);mp(330:end,:)];

SnnSum = zeros(size(mpAll(1,:)));
RnnSum = zeros(size(mpAll(1,:)));

for i = 1:size(mpAll,1)
    currRnn = autocorr(mpAll(i,:),511);
    [currPnn,f] = periodogram(double(mpAll(i,:))',rectwin(512),512,1/0.17);
    currSnn = fft(currRnn,512);
    RnnSum = RnnSum + currRnn;
    SnnSum = SnnSum + currSnn;
    if i > 1
        PnnSum = PnnSum + currPnn;
    else
        PnnSum = currPnn;
    end
end

Snn = SnnSum / size(mpAll,1);
Rnn = RnnSum / size(mpAll,1);
Pnn = PnnSum / size(mpAll,1);

