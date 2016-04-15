global NBITS BPS BETA FS FM EB_N0 NTAPS;
global TEST TESTFILTERGEN TESTTX TESTMAPPING TESTDEMAPPING...
    TESTRX;
TEST = 1;
TESTFILTERGEN = 0;
TESTTX = 0;
TESTRX = 0;
TESTDEMAPPING = 1;
TESTMAPPING = 0;

BPS = 2; %Bits per symbol
NBITS = 10000; %SE
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter
FS = 10e6; %Sample frequency
FM = 1e6; %symbol frequency, also the cutoff frequency for the rrc filters
EB_N0 = 10; %ratio of energy_bit/noise energy in dB

close all;

sent = bitGenerator(); %creation of message of bits


signal = noise(Tx(sent));

%receiver
received = Rx(signal);

if TEST && TESTRX
    figure;
    stem(sent - received);
end
