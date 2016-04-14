function message = Rx(signal)
    global BETA FM FS BPS NTAPSHALF;
    global TEST TESTDEMAPPING;

    nTaps = NTAPSHALF*2+1;
    %% Nyquist filer (rrc) 
    h_rrc = rrcosfilter(BETA,FM);
    oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
    oversampled = oversampled(nTaps:end-nTaps+1); % to get the right length after convolution we discard the RRCtaps-1 first samples
    size(oversampled)
    %% downsampling
    modulated = oversampled(1:ceil(FS/FM)-1:end);
    size(modulated)
    if TEST && TESTDEMAPPING
        figure;
        scatter(real(modulated), imag(modulated)); % show the constellation
    end

    %input vector must be column vector
    message = demapping(modulated,BPS,'qam'); % send message to demodulator function

end
