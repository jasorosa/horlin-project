function h = rrcosfilter(beta, fm)
    global FS NTAPS TEST TESTFILTERGEN;
    H = zeros(NTAPS,1);
    fmax = FS*(NTAPS-1)/(2*NTAPS);
    f = linspace(-fmax, fmax, NTAPS);

    for i=1:NTAPS
        if abs(f(i)) <= (1-beta)*fm/2
            H(i) = 1/fm;
        elseif abs(f(i)) <= (1+beta)*fm/2
            tm = 1/fm;
            H(i) = tm/2*(1+cos(pi*(tm/beta)*(abs(f(i))-(1-beta)*fm/2)));
       end
    end
    
    h = ifftshift(ifft(sqrt(H*fm), 'symmetric'));

    if TEST && TESTFILTERGEN
        figure;
        plot(f, H, '-o');
        
        t = (-(NTAPS-1)/2:(NTAPS-1)/2)*(1/fmax);
        figure;
        plot(t,h);
        grid on;
        
        figure;
        plot(f, fftshift(fft(h)));
    end
end
