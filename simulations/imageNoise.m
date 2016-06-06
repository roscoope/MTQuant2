%%% imageNoise
%%% Randomly generate a noise signal of length len using PSD Sxx
%%% 
%%% Input Arguments
%%% len = signal length
%%% Sxx = noise PSD generated using getNoiseProfile.m
%%%
%%% Output Arguments
%%% noise = randomly generated noise signal of length len from PSD Sxx

function noise = imageNoise(len,Sxx)

Hw = sqrt (Sxx); %%% Compute Fourier transform of LTI filter
temp = Hw;
temp(1) = 0;
g = gaussmf(-255:256,[20,0]);
g2 = [g(256:end),g(1:255)];
temp2 = temp .* g2;
temp2(1) = Hw(1);
hn = ifft (temp2); %%% Get filter coefficients
hn = abs(hn);
wn = randn (len,1); %%% Generate a very large input WGN sequence
xprime = filter (hn, 1, wn); %%% Filter to get output
noise = xprime;

