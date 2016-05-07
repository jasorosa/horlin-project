function h = rrcosfilter(beta, fm, ntaps)
    global FS;
    global TFILTERGEN;
    global ANYQUIST ACFOISI;

    nsamps = ntaps * FS/fm + 1;
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

    h = fftshift(ifft(ifftshift(sqrt(H)), 'symmetric'));
    norm = max(conv(h,h));
    h = h./sqrt(norm);

    if TFILTERGEN
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
        plot(tisi,isi,'or', 'MarkerSize', 7);
        offset = 0.1*(-1).^(1:length(isi))';
        text(tisi,isi+offset,num2str(isi), 'HorizontalAlignment', 'center', 'rotation',30, 'fontsize', 13, 'FontWeight', 'bold');
        title('Cancellation of the ISI of an RC filter');
        xlabel('time [s]');
        ylabel('Value [arbitrary]');
        box on;
        legend('RRC filter convoluted with itself', sprintf('Convolution result sampled at the symbol frequency '));
    end

    if ACFOISI
        f = figure; hold on; grid on;
        set(findall(f,'-property','FontSize'),'FontSize',17);
        set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
        cfoppm = 10;
        autoConv = conv(h,cfo(h,2e9*cfoppm*1e-6,0));
        isi = smpFromCenter(autoConv,FS/fm);
        tautoconv = (-(length(autoConv)-1)/2:(length(autoConv)-1)/2) * (1/(2*fmax));
        tisi = smpFromCenter(tautoconv',FS/fm);
        plot(tautoconv, real(autoConv), 'LineWidth', 1);
        plot(tisi,real(isi),'or', 'MarkerSize', 7);
        offset = max(real(isi))/12*(-1).^(0:length(isi)-1)';
        text(tisi,real(isi+offset),num2str(real(isi)), 'HorizontalAlignment', 'center', 'rotation',30, 'fontsize', 13, 'FontWeight', 'bold');
        title(sprintf('Impact of the CFO on the ISI of the pair of RRC filter\nCFO=%dppm',cfoppm));
        xlabel('time [s]');
        ylabel('Value [arbitrary]');
        box on;
        legend('Impulse response of the RRC-CFO-RRC system', sprintf('Response sampled at the symbol frequency '));
    end
end
