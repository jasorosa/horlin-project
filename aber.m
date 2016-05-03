clear all; close all;

global FS;

FS = 10e6;

NSYM = 1e3;

BETA = 0.3;
FM = 1e6;
NTAPS = 20;

h = rrcosfilter(BETA, FM, NTAPS);

f = figure;

bps = 2:2:8;
ebn0 = -10:.5:25;
bers = zeros(length(bps),length(ebn0));
for i = 1:length(bps)
    nbits = bps(i)*NSYM;
    sent = bitGenerator(nbits);
    for j = 1:length(ebn0)
        modulated = mapping(sent, bps(i), 'qam');
        
        upsampled = upsample(modulated,FS/FM);
        out = conv(h, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

        signal = awgn(out, ebn0(j), nbits);

        oversampled = conv(signal, h); % len = len(h_rrc)+len(upsampledMes)-1
        oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples
        modulated = oversampled(1:FS/FM:end);

        modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);
        received = demapping(modulated,bps(i),'qam'); % send message to demodulator function
        bers(i,j) = sum(abs(received-sent))/nbits;
    end
    semilogy(ebn0,bers(i,:),'-o','DisplayName',sprintf('%d-QAM', 2^bps(i)), 'LineWidth',2);hold all;grid on;
end
title('BER curves for different QAMs');
xlabel('SNR per bit [dB]');
ylabel('BER');
legend('-DynamicLegend');
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');