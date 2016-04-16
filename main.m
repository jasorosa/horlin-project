global NBITS BPS BETA FS FM E_B_OVER_N_0 NTAPS;
global TEST TESTFILTERGEN TESTTX TESTMAPPING TESTDEMAPPING...
    TESTRX;
TEST = 0;
TESTFILTERGEN = 0;
TESTTX = 0;
TESTRX = 1;
TESTDEMAPPING = 1;
TESTMAPPING = 0;

BPS = 2; %Bits per symbol
NBITS = 10000; %SE
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter
FS = 10e6; %Sample frequency
FM = 1e6; %symbol frequency, also the cutoff frequency for the rrc filters
E_B_OVER_N_0 = 10; %ratio of energy_bit/noise energy in dB (typ. 10)

close all;

sent = bitGenerator(); %creation of message of bits

received = Rx(awgn(Tx(sent), E_B_OVER_N_0));

if TEST && TESTRX
    figure;
    stem( abs(sent - received));
end
