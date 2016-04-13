function receivedMessage = noise(mesToSend)
    global FS FM EB_N0
    % SignalEnergy=meanPowerSignal(mesToSend);
    SignalEnergy = trapz(abs(mesToSend).^2)*(1/FS);
    Eb = SignalEnergy/FM; % Fm = symbol frequency
    N0 = Eb/10^(EB_N0/10); % Eb_N0 is the ratio energy_bit / noise power in dB, we can choose like 10dB
    % N0 = NoisePower / Bandwidth
    NoisePower = 2*N0*FS; % mean power of the noise, Fs is sample frequency
    receivedMessage = mesToSend+sqrt(NoisePower/2)* (randn(size(mesToSend)) + 1i*randn(size(mesToSend)));
end