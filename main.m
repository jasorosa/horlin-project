%Main  project. 
% Call all other function 
numberOfBits=100;

Fs=20000; % Sample frequency
Fm=500; % symbol frequency
Eb_N0=10; % ratio of energy_bit/noise energy in dB

message=bitGenerator(numberOfBits); %creation of message of bits

%send to sender
mesToSend=Tx(message);

%add noise

%receivedMes=noise(mesToSend, Fs, Fm, Eb_N0); % message read at the receiver

%receiver
messageBack = Rx(mesToSend);
figure
stem(message)
hold on
stem(messageBack,'r')