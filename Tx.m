function signal = Tx(message, h_rrc, bps)
    global FM FS;
    global TMAPPING;
    global ANYQUIST;

    %input vector must be column vector
    modulated = mapping(message, bps, 'qam');
    if TMAPPING
        figure;
        scatter(real(modulated), imag(modulated));
    end

    %% upsampling
    upsampled = upsample(modulated,FS/FM);

    %% Nyquist filer (rrc)
    signal=conv(h_rrc, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

    if ANYQUIST
        f = figure; hold all; grid on;
        set(findall(f,'-property','FontSize'),'FontSize',17);
        set(findall(f,'-property','FontName'),'FontName', 'Helvetica');

        pBefore = pwelch(upsampled,hann(1024));
        pAfter = pwelch(signal,hann(1024));

        rxFiltered = conv(h_rrc, signal);
        pAfter2 = pwelch(rxFiltered,hann(1024));

        plot(linspace(-FS/2, FS/2, length(pBefore)), 10*log10(fftshift(pBefore)));
        plot(linspace(-FS/2, FS/2, length(pAfter)), 10*log10(fftshift(pAfter)));
        plot(linspace(-FS/2, FS/2, length(pAfter2)), 10*log10(fftshift(pAfter2)));
        title(sprintf('Effect of the Nyquist filtering on the communication bandwidth: \n Spectral density of the signal'));
        xlabel('Frequency [Hz]');ylabel('Power [dB/Hz]');
        legend('Before filtering','After 1 rrc filter pass (Tx)','After 2 rrc filter passes (Rx)');
    end
end
