function signal = Tx(message, h_rrc)
    global FM FS BPS;
    global TEST ASSIGNMENT;
    global TESTMAPPING ANYQUIST;

    %input vector must be column vector
    modulated = mapping(message, BPS, 'qam');
    if TEST && TESTMAPPING
        figure;
        scatter(real(modulated), imag(modulated));
    end
    
    %% upsampling
    upsampled = upsample(modulated,FS/FM);
    
    %% Nyquist filer (rrc)     
    signal=conv(h_rrc, upsampled); % len = len(h_rrc)+len(upsampledMes)-1
end
