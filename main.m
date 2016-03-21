%Main  project. 
% Call all other function 
global NBITS BPS BETA FS FM EB_N0;


BPS = 2; %Bits per symbol
NBITS = 100; %SE
BETA = 0.25; %Rolloff factor
FS = 2e4; %Sample frequency
FM = 5e2; %symbol frequency
EB_N0 = 10; %ratio of energy_bit/noise energy in dB

message = bitGenerator(); %creation of message of bits

%send to sender
mesToSend = Tx(message);

%add noise

%receivedMes = noise(mesToSend); % message read at the receiver

%receiver
messageBack = Rx(mesToSend);
figure
stem(message)
hold on
stem(messageBack,'r')