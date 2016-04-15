function message = Rx(signal)
    global BETA FM FS BPS NTAPS;
    global TEST TESTDEMAPPING;

    %% Nyquist filer (rrc) 
    h_rrc = rrcosfilter(BETA,FM);
    oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
    oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples
    %% downsampling
    modulated = oversampled(1:ceil(FS/FM):end);
    if TEST && TESTDEMAPPING
        figure;
        scatter(real(modulated), imag(modulated)); % show the constellation
    end

    %input vector must be column vector
    message = demapping(modulated,BPS,'qam'); % send message to demodulator function

end
