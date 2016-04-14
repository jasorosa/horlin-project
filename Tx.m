function signal = Tx(message)
    global BETA FM FS BPS;
    global TEST TESTMAPPING;

    %input vector must be column vector
    modulated = mapping(message, BPS, 'qam');
    if TEST && TESTMAPPING
        figure;
        scatter(real(modulated), imag(modulated));
    end
    
    %% upsampling
    upsampled = upsample(modulated,FS/FM);
    
    %% Nyquist filer (rrc)     
    h_rrc = rrcosfilter(BETA, FM);
    signal=conv(h_rrc, upsampled); % len = len(h-rrc)+len(upsampledMes)-1
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
