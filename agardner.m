close all; clear all;

global FS FM FSGARDNER;
global AGARDNER;

AGARDNER = 1;

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
FSGARDNER = 4*FM;
K = 10;
DSMP = 40;

sent = bitGenerator(NBITS);
h_rrc = rrcosfilter(BETA, FM, NTAPS);

modulated = mapping(sent, BPS, 'qam');

upsampled = upsample(modulated,FS/FM);

out = conv(h_rrc, upsampled);

signal = cfo(awgn(out, E_B_OVER_N_0, NBITS), DF*FC, 0);

oversampled = conv(signal, h_rrc);
oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM));

gardnersampled = oversampled(1+DSMP:FS/FSGARDNER:end);

modulated = gardner(gardnersampled, K);

modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);

received = demapping(modulated,BPS,'qam');
