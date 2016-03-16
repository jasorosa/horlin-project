function receivedMessage = noise(mesToSend, Fs, Fm, Eb_N0)
    Ps=meanPowerSignal(mesToSend);
    Eb = Ps/Fm; % Fm = symbol frequency
    N0 = Eb/10^(Eb_N0/10); % Eb_N0 is the ratio energy_bit / noise power in dB, we can choose like 10dB
    Pw = 0.5*N0*Fs; % mean power of the noise, Fs is sample frequency
    receivedMessage = mesToSend+sqrt(Pw)*randn(size(mesToSend));
end