function h = rrcosfilter(beta, fm)
    global FS NTAPS;
    global TEST TESTFILTERGEN;
    global ANYQUIST ACFOISI;

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

        t = (-(nsamps-1)/2:(nsamps-1)/2)*(1/(2*fmax));
        figure;
        plot(t,h);
        title('Time response of the filter')
        grid on;
    end

    if ANYQUIST
        f = figure; hold on; grid on;
        set(findall(f,'-property','FontSize'),'FontSize',17);
        set(findall(f,'-property','FontName'),'FontName', 'Helvetica');

        autoConv = conv(h,h);
        isi = smpFromCenter(autoConv,FS/fm);
        tautoconv = (-(length(autoConv)-1)/2:(length(autoConv)-1)/2) * (1/(2*fmax));
        tisi = smpFromCenter(tautoconv',FS/fm);
        plot(tautoconv, autoConv, 'LineWidth', 1);
        plot(tisi,isi,'o', 'MarkerSize', 7);
        title('Cancellation of the ISI of an RRC filter');
        xlabel('time [s]');
        ylabel('Value [arbitrary]');
        box on;
        legend('RRC filter convoluted with itself', sprintf('Convolution result sampled at the symbol frequency '));
    end

    if ACFOISI
        f = figure; hold on; grid on;
        set(findall(f,'-property','FontSize'),'FontSize',17);
        set(findall(f,'-property','FontName'),'FontName', 'Helvetica');

        autoConv = angle(conv(h,cfo(h,10e-6*2e9,0)));
        isi = smpFromCenter(autoConv,FS/fm);
        tautoconv = (-(length(autoConv)-1)/2:(length(autoConv)-1)/2) * (1/(2*fmax));
        tisi = smpFromCenter(tautoconv',FS/fm);
        plot(tautoconv, autoConv, 'LineWidth', 1);
        plot(tisi,isi,'o', 'MarkerSize', 7);
        title('Cancellation of the ISI of an RRC filter');
        xlabel('time [s]');
        ylabel('Value [arbitrary]');
        box on;
        legend('RRC filter convoluted with itself', sprintf('Convolution result sampled at the symbol frequency '));
    end
end
