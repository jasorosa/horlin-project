close all; clear all;

global FS FM FSGARDNER;
global TFILTERGEN TMAPPING TDEMAPPING...
    TRX TGARDNER;

TFILTERGEN = 0;
TRX = 1;
TDEMAPPING = 0;
TMAPPING = 0;
TGARDNER = 1;

%general
NSYM = 1e3;
FS = 100e6;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
BPS = 2; %Bits per symbol
NBITS = BPS*NSYM; %SE

%noise
E_B_OVER_N_0 = 10; %ratio of energy_bit/noise energy in dB (typ. 10)

%rrc filter
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter

%cfo
FC = 2e9; %for CFO
DF = 0;

%Gardner
FSGARDNER = 8*FM;
K = 10;
DSMP = 30;

%frame acquisition
N = 40;
KWIN = 12;

sent = bitGenerator(NBITS);
h_rrc = rrcosfilter(BETA, FM, NTAPS);
pilotSymbol = mapping(sent(1:N), BPS, 'qam');

modulated = mapping(sent, BPS, 'qam');
if TMAPPING
   figure;
   scatter(real(modulated), imag(modulated));
end

upsampled = upsample(modulated,FS/FM);

out = conv(h_rrc, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

signal = cfo(awgn(out, E_B_OVER_N_0, NBITS), DF*FC, 0);

oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples

gardnersampled = oversampled(1+DSMP:FS/FSGARDNER:end);

modulated = gardner(gardnersampled, K);

%[nHat cfoHat] = frameAcq(pilotSymbol, modulated, N, KWIN);

modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);
if TDEMAPPING
    figure;
    scatter(real(modulated), imag(modulated)); % show the constellation
end

%input vector must be column vector
received = demapping(modulated,BPS,'qam'); % send message to demodulator function

if TRX
    figure;
    stem( abs(sent - received));
end
