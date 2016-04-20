function message = Rx(signal, h_rrc, bps, varargin)
    global FM FS NTAPS NSYM;
    global TEST TESTDEMAPPING;
    MANUALCFOCORR = 0;

    if length(varargin) == 1
        df = varargin{1};
        MANUALCFOCORR = 1;
    end
        
    %% Nyquist filer (rrc)
    oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
    oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples
    %% downsampling
    if MANUALCFOCORR
        t = (0:length(oversampled)-1) ./ FS;
        cfo = exp((-1j*2*pi*df).* (t+t(NTAPS*ceil(FS/(2*FM)))));
        oversampled = oversampled .* cfo';
    end
        
    modulated = oversampled(1:ceil(FS/FM):end);
    modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);
    if TEST && TESTDEMAPPING
        figure;
        scatter(real(modulated), imag(modulated)); % show the constellation
    end

    %input vector must be column vector
    message = demapping(modulated,bps,'qam'); % send message to demodulator function

end
