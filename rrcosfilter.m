function h = rrcosfilter(beta, fm)
    global FS NTAPS TEST TESTFILTERGEN;

    nsamps = NTAPS * FS/fm + 1;
    H = zeros(nsamps,1);
    fmax = FS*(nsamps-1)/(2*nsamps);
    f = linspace(-fmax, fmax, nsamps);

    for i=1:nsamps
        if abs(f(i)) <= (1-beta)*fm/2
            H(i) = 1/fm;
        elseif abs(f(i)) <= (1+beta)*fm/2
            tm = 1/fm;
            H(i) = tm/2*(1+cos(pi*(tm/beta)*(abs(f(i))-(1-beta)*fm/2)));
       end
    end
    
    %h = ifftshift(ifft(sqrt(fftshift(fft(ifft(H, 'symmetric')*fm))), 'symmetric')); % normalization + ifft
    h = ifftshift(ifft(fftshift(sqrt(H)), 'symmetric'));
    h = h./max(h);
    h = [h(2:end);h(1)];%FUCK MATLAB
    % h(ceil(NTAPS/2))

    if TEST && TESTFILTERGEN
        figure;
        plot(f, H, '-o');
        title('Frequency response of the filter')
        
        t = (-(nsamps-1)/2:(nsamps-1)/2)*(1/2*fmax);
        figure;
        plot(t,h);
        title('Time response of the filter')
        grid on;
    end
end
