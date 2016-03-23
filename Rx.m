function message = Rx(signal)
    global BETA FM FS BPS NTAPS;
    global TEST TESTDEMAPPING;

    %% Nyquist filer (rrc) 
    h_rrc = rrcosfilter(BETA,FM);

<<<<<<< HEAD
sps = 4; % must match with multiplier
span = 16; % will have to be 16*sps+1
% G = rcosdesign(beta,span,sps,'sqrt'); % TODO !
RRCTaps = (span*sps)+1;
[H_rc, f, fmax] = rcosfilter(beta,RRCTaps, 1/Fm, Fs);
G = sqrt(H_rc*Fm);
=======
    oversampled = conv(signal, h_rrc); % len = len(G)+len(upsampledMes)-1
    oversampled = oversampled(NTAPS:end-NTAPS+1); % to get the right length after convolution we discard the RRCtaps-1 first samples
>>>>>>> a5d587d9ad53779d53ea2e66a7e2e8ba301519a9

    %% downsampling
    modulated = oversampled(1:ceil(FS/FM):end);

    if TEST && TESTDEMAPPING
        figure;
        scatter(real(modulated), imag(modulated)); % show the constellation
    end

    %input vector must be column vector
    message = demapping(modulated,BPS,'qam'); % send message to modulator function
    %need to know the number of bit per symbol !!!!

end
