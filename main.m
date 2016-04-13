global NBITS BPS BETA FS FM EB_N0 NTAPSHALF;
global TEST TESTFILTERGEN TESTTX TESTMAPPING TESTDEMAPPING TESTFILTERING...
    TESTRX;
TEST = 1;
TESTFILTERGEN = 1;
TESTFILTERING = 0;
TESTTX = 0;
TESTRX = 0;
TESTDEMAPPING = 1;
TESTMAPPING = 0;

BPS = 2; %Bits per symbol
NBITS = 10000; %SE
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPSHALF = 50; %of the RRC filter
FS = 10e6; %Sample frequency
FM = 1e6; %symbol frequency, also the cutoff frequency for the rrc filters
EB_N0 = 10; %ratio of energy_bit/noise energy in dB

close all;

sent = bitGenerator(); %creation of message of bits

%send to sender
signal = Tx(sent);

%add noise
%receivedMes = noise(mesToSend); % message read at the receiver

%receiver
received = Rx(signal);

if TEST && TESTRX
    figure;
    stem(sent - received);
end
