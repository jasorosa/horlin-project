close all; clear all;

global FS FM;

%general
NSYM = 1e4;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
FS = 16*FM;
BPS = 2; %Bits per symbol
NBITS = BPS*NSYM; %SE

%noise
E_B_OVER_N_0 = 10; %ratio of energy_bit/noise energy in dB (typ. 10)

%rrc filter
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter

%cfo
FC = 2e9; %for CFO
DF = 10e-6;


sent = bitGenerator(NBITS);
h_rrc = rrcosfilter(BETA, FM, NTAPS);

modulated = mapping(sent, BPS, 'qam');

upsampled = upsample(modulated,FS/FM);

out = conv(h_rrc, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

noisy = awgn(out, E_B_OVER_N_0, NBITS);
signal = cfo(noisy, DF*FC, 0);

oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples

rmodulated=oversampled(1:FS/FM:end);

rmodulated = rmodulated/sqrt(sum(abs(modulated).^2)/NSYM);

oversampled = conv(noisy, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples

nmodulated=oversampled(1:FS/FM:end);

nmodulated = nmodulated/sqrt(sum(abs(modulated).^2)/NSYM);


f=figure; hold all;
plot(real(rmodulated), imag(rmodulated), 'ok'); % show the constellation
plot(real(nmodulated), imag(nmodulated), 'sb', 'MarkerSize', 7);
plot(real(modulated), imag(modulated),'xr', 'MarkerSize', 15, 'Linewidth', 4);
axis equal;
title('Constellation at different stages of the channel');
xlabel('Real part');
ylabel('Imaginary part');
legend('After CFO', 'After AWGN', 'At the emitter');
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
box on; grid on;
