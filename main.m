global NBITS BPS BETA FS FM EB_N0;

BPS = 2; %Bits per symbol
NBITS = 100; %SE
BETA = 0.3; %Rolloff factor
FS = 5e6; %Sample frequency
FM = 50e3; %symbol frequency
EB_N0 = 10; %ratio of energy_bit/noise energy in dB

close all;

message = bitGenerator(); %creation of message of bits

%send to sender
mesToSend = Tx(message);

%add noise

%receivedMes = noise(mesToSend); % message read at the receiver

%receiver
messageBack = Rx(mesToSend);

figure;
stem(message - messageBack);