clear all; close all;

global FS;

FS = 32e6;

BETA = 0.3;
FM = 1e6;
NTAPS = 20;

NSYM = 1e6;

BPS = 4;
NBITS = BPS*NSYM;

h = rrcosfilter(BETA, FM, NTAPS);

f = figure;

smpshift = [0 1 2 3 4 8 16];
ebn0 = -10:1:25;
bers = zeros(length(smpshift),length(ebn0));
sent = bitGenerator(NBITS);
for i = 1:length(smpshift)
    for j = 1:length(ebn0)
        fprintf('eps: %d/%d, noise: %d/%d\n', i, length(smpshift), j, length(bers));
        modulated = mapping(sent, BPS, 'qam');
        
        upsampled = upsample(modulated,FS/FM);
        out = conv(h, upsampled);

        signal = awgn(out, ebn0(j), NBITS);
        
        oversampled = conv(signal, h);
        
        oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples
        modulated = oversampled(1+smpshift(i):FS/FM:end);

        modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);
        received = demapping(modulated,BPS,'qam'); % send message to demodulator function
        bers(i,j) = sum(abs(received-sent))/NBITS;
    end
    semilogy(ebn0,bers(i,:),'-o','DisplayName',sprintf('Epsilon = %g', smpshift(i)/(FS/FM)), 'LineWidth',2);hold all;grid on;
end
title('Impact of sample time shift on BER');
xlabel('E_b/N_0[dB]');
ylabel('BER');
legend('-DynamicLegend');
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
ylim([10/NSYM inf]);
