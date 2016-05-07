clear all; close all;

global ANYQUIST;
global FS;

ANYQUIST = 1;

FS = 10e6;
NBITS = 1e4;
BPS = 4;
FM = 1e6;
E_B_OVER_N_0 = 10;

h = rrcosfilter(0.3, 1e6, 20);
h = h./trapz(abs(h));

sent = bitGenerator(NBITS);
modulated = mapping(sent, BPS, 'qam');

upsampled = upsample(modulated,FS/FM);

out = conv(h, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

signal = awgn(out, E_B_OVER_N_0, NBITS);

oversampled = conv(signal, h); % len = len(h_rrc)+len(upsampledMes)-1

f = figure; hold all; grid on;
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');

pRaw = pwelch(upsampled,hann(1024));
norm = mean(abs(pRaw));
pRaw = pRaw./norm;
pTx = pwelch(out,hann(1024))./norm;
pNoised = pwelch(signal,hann(1024))./norm;
pRx = pwelch(oversampled,hann(1024))./norm;

plot(linspace(-FS/2, FS/2, length(pRaw)), 10*log10(fftshift(pRaw)));
plot(linspace(-FS/2, FS/2, length(pTx)), 10*log10(fftshift(pTx)));
plot(linspace(-FS/2, FS/2, length(pNoised)), 10*log10(fftshift(pNoised)));
plot(linspace(-FS/2, FS/2, length(pNoised)), 10*log10(fftshift(pRx)));
title(sprintf('Effect of the Nyquist filtering on the communication bandwidth: \n Spectral density of the signal'));
xlabel('Frequency [Hz]');ylabel('Power [dB/Hz]');
legend('Signal at the emitter before filtering','Transmitted signal',sprintf('Received signal (noisy: E_b/N_0 = %d db)', E_B_OVER_N_0), 'Signal at the receiver after filtering');
