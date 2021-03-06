clear all; close all;

global FS;

FS = 10e6;

NSYM = 1e3;

BPS = 4;
NBITS = NSYM*BPS;

BETA = 0.3;
FM = 1e6;
NTAPS = 20;

FC = 2e9;

h = rrcosfilter(BETA, FM, NTAPS);
sent = bitGenerator(NBITS);

f = figure;

df = [0 25 50 75 100].*(1e-6*FC);
ebn0 = -10:.5:25;
bers = zeros(length(df),length(ebn0));
for i = 1:length(df)
    for j = 1:length(ebn0)
        fprintf('df: %d/%d, noise: %d/%d\n', i, length(df), j, length(bers));
        modulated = mapping(sent, BPS, 'qam');
        
        upsampled = upsample(modulated,FS/FM);
        out = conv(h, upsampled);

        signal = awgn(out, ebn0(j), NBITS);
        signal = cfo(signal, df(i), 0);
        
        oversampled = conv(signal, h);

        %Manual perfect cfo correction after filtering
        oversampled = cfo(oversampled, -df(i), NTAPS*2*pi*df(i)/(2*FM));
        
        oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples
        modulated = oversampled(1:FS/FM:end);

        modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);
        received = demapping(modulated,BPS,'qam'); % send message to demodulator function
        bers(i,j) = sum(abs(received-sent))/NBITS;
    end
    semilogy(ebn0,bers(i,:),'-o','DisplayName',sprintf('CFO = %d ppm', df(i)/FC * 1e6), 'LineWidth',2);hold all;grid on;
end
title(sprintf('Impact of perfectly compensated (ISI only) CFO on BER\n%d-QAM', 2^BPS));
xlabel('E_b/N_0[dB]');
ylabel('BER');
legend('-DynamicLegend');
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
ylim([10/NSYM inf]);
