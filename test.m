close all;

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

E_B_OVER_N_0 = 10; %ratio of energy_bit/noise energy in dB (typ. 10)

BPS = 2; %Bits per symbol
NBITS = BPS*NSYM; %SE

sent = bitGenerator(NBITS);
h_rrc = rrcosfilter(BETA,FM);

pilotSymbol = mapping(sent(1:40), BPS, 'qam');

out = Tx(sent, h_rrc, BPS);
signal = cfo(awgn(out, E_B_OVER_N_0), 20e-6*FC, 0);
received = Rx(signal, h_rrc, BPS, pilotSymbol, 0, 0);


