function mes = Rx(ReceivedMes)

    global BETA FM FS BPS;

    %% Nyquist filer (rrc) 
    [H_rc] = rcosfilter(BETA,FM);
    G = sqrt(H_rc*FM);

    h_rrc = ifftshift(ifft(G));

    % plot(t,h_rrc);

    % square root nyquist pulse filter , truncated to span symbols, each symbol period has sps samples
    mesOversample=conv(ReceivedMes, G); % len = len(G)+len(upsampledMes)-1
    mesOversample=mesOversample(RRCTaps:end-RRCTaps+1); % to get the right length after convolution we discard the RRCtaps-1 first samples

    gg = conv(G,G);
    plot(gg)


    %% downsampling
    downsampled = mesOversample(1:ceil(FS/FM):end);

    figure
    scatter(real(downsampled), imag(downsampled)); % show the constellation

    %input vector must be column vector
    mes=demapping(downsampled,BPS,'qam'); % send message to modulator function
    %need to know the number of bit per symbol !!!!

end
