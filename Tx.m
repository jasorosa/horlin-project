function signal = Tx(message)
    global BETA FM FS BPS;
    global TEST TESTTX TESTMAPPING;

    %input vector must be column vector
    modulated = mapping(message, BPS, 'qam');
    if TEST && TESTMAPPING
        figure;
        scatter(real(modulated), imag(modulated));
        plot(linspace(-FM/2,FM/2,length(modulated)),abs(fftshift(fft(modulated))));
    end
    
    %% upsampling
    upsampled = upsample(modulated,FS/FM-1);
    
    %% Nyquist filer (rrc)     
    h_rrc = rrcosfilter(BETA, FM);
    signal=conv(h_rrc,upsampled); % len = len(G)+len(upsampledMes)-1
    if TEST && TESTTX
        figure;
        plot(linspace(-FS/2, FS/2, length(upsampled)), 20*log10(abs(fftshift(fft(upsampled)))), '-o', ...
        linspace(-FS/2, FS/2, length(signal)), 20*log10(abs(fftshift(fft(signal)))), '-o');
    end
end

% taps of the filter : time extension & frequency resolution
% RRCTaps = length(H(f))
% Fax=Fs/2
% f=linspace(-fmax,fmax,RRCTaps)
% may need to normalize H to get impulse =1 at t=0
% Delta_T = 1/2fmax
% t=((-RRCTaps-1)/2:(RRCTaps-1)/2)*delta_t
% use ifft ifftshift !


% length(conv(vec1)) !=length(vec1) !!
% use mlf2pdf
