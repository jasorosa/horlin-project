close all; clear all;

global NBITS NSYM BETA FS FM E_B_OVER_N_0 NTAPS K FC;
global TFILTERGEN TMAPPING TDEMAPPING...
    TRX TGARDNER;

TFILTERGEN = 1;
TRX = 0;
TDEMAPPING = 0;
TMAPPING = 0;
TGARDNER = 0;

FC = 2e9; %for CFO

NSYM = 1e3;
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 100; %of the RRC filter
FS = 100e6;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
K = 0;
N = 40;

E_B_OVER_N_0 = 10; %ratio of energy_bit/noise energy in dB (typ. 10)

BPS = 2; %Bits per symbol
NBITS = BPS*NSYM; %SE

sent = bitGenerator(NBITS);
h_rrc = rrcosfilter(BETA,FM);
pilotSymbol = mapping(sent(1:N), BPS, 'qam');

modulated = mapping(message, bps, 'qam');
if TMAPPING
   figure;
   scatter(real(modulated), imag(modulated));
end

upsampled = upsample(modulated,FS/FM);

out = conv(h_rrc, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

signal = cfo(awgn(out, E_B_OVER_N_0), 20e-6*FC, 0);

oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples


