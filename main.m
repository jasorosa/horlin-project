global NBITS BPS BETA FS FM EB_N0 NTAPS;
global TEST TESTFILTER TESTTX TESTMAPPING TESTDEMAPPING;
TEST = 1;
TESTFILTER = 1;
TESTTX = 0;
TESTDEMAPPING = 0;
TESTMAPPING = 0;

BPS = 2; %Bits per symbol
NBITS = 1000; %SE
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 65; %of the RRC filter
FS = 10e6; %Sample frequency
FM = 1e6; %symbol frequency, also the cutoff frequency for the rrc filters
EB_N0 = 10; %ratio of energy_bit/noise energy in dB

close all;

sent = bitGenerator(); %creation of message of bits

%send to sender
signal = Tx(sent);

%add noise
signal = noise(signal); % message read at the receiver

%receiver
received = Rx(signal);

if TEST
    figure;
    stem(sent - received);
    title('Message sent - Message received')
end
