function noisy = awgn(signal, EBN0, nbits)
    global FS;

    E_b = trapz(abs(signal).^2) / (FS*nbits*2);
    N_0 = E_b / 10^(EBN0/10);

    NoisePower = 2*N_0*FS;
    noisy = signal + sqrt(NoisePower/2)...
        .* (randn(size(signal)) + 1i*randn(size(signal)));
end
