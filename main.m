%Main  project. 
% Call all other function 
numberOfBits=100;

beta = 0.25;
Fs = 2e4; % Sample frequency
Fm = 5e2; % symbol frequency
Eb_N0 = 10; % ratio of energy_bit/noise energy in dB

message=bitGenerator(numberOfBits); %creation of message of bits

%send to sender
mesToSend=Tx(message, beta, Fm, Fs);

%add noise

%receivedMes=noise(mesToSend, Fs, Fm, Eb_N0); % message read at the receiver

%receiver
messageBack = Rx(mesToSend, beta, Fm, Fs);
figure
stem(message)
hold on
stem(messageBack,'r')