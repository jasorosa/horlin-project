function h = rrcosfilter(beta, fm)
    global FS NTAPS;
    global TEST TESTFILTERGEN;
    global ANYQUIST;

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

    h = ifftshift(ifft(fftshift(sqrt(H)), 'symmetric'));
    h = h./max(h);
    h = [h(2:end);h(1)];%FUCK YOU MATLAB

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

    if ANYQUIST
        f = figure; hold all; grid on;
        set(findall(f,'-property','FontSize'),'FontSize',17);
        set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
        autoConv = conv(h,h);
        isi = smpFromCenter(autoConv,FS/fm);
        t = (-(length(autoConv)-1)/2:(length(autoConv)-1)/2) * (1/2*fmax);
        tisi = smpFromCenter(t',FS/fm);
        plot(t, autoConv, 'LineWidth', 1);
        plot(tisi,isi,'o', 'MarkerSize', 7);
        title('ISI of the raised root nyquist filter');
        xlabel('time');
        ylabel('Value');
        legend('RRC filter convoluted with itself', 'Convolution sampled every T_m');
    end

end
