function h = rrcosfilter(beta, fm)
    global FS NTAPSHALF TEST TESTFILTERGEN;

    h = sqrt(FS/fm)*rcosfir(beta, NTAPSHALF, FS/fm, 1/fm, 'sqrt');
    
    if TEST && TESTFILTERGEN
        nTaps = 2*NTAPSHALF+1;
        fmax = FS*(nTaps-1)/(2*nTaps);
        
        t = (-(nTaps-1)*FS/(2*fm):(nTaps-1)*FS/(2*fm))*(1/fmax);
        figure;
        plot(t, h);
        title('Impulse response of the root raised cosine filter');
        grid on;
        
        figure;
        plot(fftshift(abs(fft(h))));
        title('Frequency response of the root raised cosine filter');
    end
end
