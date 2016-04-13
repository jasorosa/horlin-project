function h = rrcosfilter(beta, fm)
    global FS NTAPSHALF TEST TESTFILTERGEN;
    nTaps = 2*NTAPSHALF+1;
    H = zeros(nTaps,1);
    fmax = FS*(nTaps-1)/(2*nTaps);
    f = linspace(-fmax, fmax, nTaps);

    for i=1:nTaps
        if abs(f(i)) <= (1-beta)*fm/2
            H(i) = 1/fm;
        elseif abs(f(i)) <= (1+beta)*fm/2
            tm = 1/fm;
            H(i) = tm/2*(1+cos(pi*(tm/beta)*(abs(f(i))-(1-beta)*fm/2)));
       end
    end
    
    h = ifftshift(ifft(sqrt(H*fm), 'symmetric'));
    h = sqrt(fm)*rcosfir(beta, NTAPSHALF, FS/fm, 1/fm, 'sqrt');
    l = length(h)
    
    if TEST && TESTFILTERGEN
        figure;
        plot(f, H, '-o');
        
        t = (-(nTaps-1)/2:(nTaps-1)/2)*(1/fmax);
        figure;
        plot(h);
        title('Impulse response of the root raised cosine filter');
        grid on;
        
        figure;
        plot(fftshift(abs(fft(h))));
        title('Frequency response of the root raised cosine filter');
    end
end
