function message = Rx(signal)
    global BETA FM FS BPS NTAPS;
    global TEST TESTDEMAPPING;

    %% Nyquist filer (rrc) 
    h_rrc = rrcosfilter(BETA,FM);

    % h_rrc = rcosdesign(BETA,6.4,10);
    
    oversampled = conv(signal, h_rrc); % len = len(G)+len(upsampledMes)-1
    oversampled = oversampled(NTAPS:end-NTAPS+1); % to get the right length after convolution we discard the RRCtaps-1 first samples
    % size(oversampled)
    %% downsampling
    modulated = oversampled(1:ceil(FS/FM)-1:end);
    % size(modulated)
    if TEST && TESTDEMAPPING
        figure;
        scatter(real(modulated), imag(modulated)); % show the constellation
        title('constellation')
    end

    %input vector must be column vector
    message = demapping(modulated,BPS,'qam'); % send message to modulator function
    % size(message)
    %need to know the number of bit per symbol !!!!

end
