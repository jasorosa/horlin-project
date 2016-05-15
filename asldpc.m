close all; clear all;

global FS FM;
global TFILTERGEN TMAPPING TDEMAPPING TRX TGARDNER;

TFILTERGEN = 0;
TRX = 1;
TDEMAPPING = 0;
TMAPPING = 0;
TGARDNER = 1;

%general
NSYM = 2^19;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
FS = 4*FM;
BPS = 1; %Bits per symbol
NBITS = BPS*NSYM; %SE

%noise
E_B_OVER_N_0 = [linspace(-10,0,7) linspace(.5,12,40)]; %ratio of energy_bit/noise energy in dB (typ. 10)

%rrc filter
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter

%LDPC
IBLKSIZE = 128;
RATIO = 2;
CBLKSIZE = RATIO*IBLKSIZE;
MAXITER = 1:4;
H0 = makeLDPC(IBLKSIZE, CBLKSIZE, 0, 1, 3);

infobits = bitGenerator(NBITS);
[checkbits, H] = makeParityChk(infobits(1:IBLKSIZE), H0, 0);
sent = [checkbits;infobits(1:IBLKSIZE)];
for blkstart = IBLKSIZE+1:IBLKSIZE:NBITS
    [checkbits, ~] = makeParityChk(infobits(blkstart:blkstart+IBLKSIZE-1), H0, 0);
    sent = [sent;checkbits;infobits(blkstart:blkstart+IBLKSIZE-1)];
end

h_rrc = rrcosfilter(BETA, FM, NTAPS);

modulated = mapping(sent, BPS, 'pam');

upsampled = upsample(modulated,FS/FM);

out = conv(h_rrc, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

rawBer = zeros(length(E_B_OVER_N_0),1);
hardBer = zeros(length(E_B_OVER_N_0), 1);
softBer = zeros(length(E_B_OVER_N_0),length(MAXITER));

f = figure;

for i = 1:length(E_B_OVER_N_0)
    fprintf('noise: %d/%d EB/N0 = %ddB\n', i, length(E_B_OVER_N_0), E_B_OVER_N_0(i));
    signal = awgn(out, E_B_OVER_N_0(i), length(sent));

    oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
    oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples

    modulated = oversampled(1:FS/FM:end);

    %input vector must be column vector
    received = demapping(modulated,BPS,'pam'); % send message to demodulator function
    rawBer(i) = sum(abs(received-sent))/length(received);
    hardinfobits = decoder(received,H, 5);
    hardBer(i) = sum(abs(hardinfobits - infobits))/length(infobits);
    for j = 1:length(MAXITER)
        softinfobits = sbldemapper(modulated, H, MAXITER(j));
        softBer(i,j) = sum(abs(softinfobits - infobits))/length(infobits);
    end
end

semilogy(E_B_OVER_N_0,rawBer,'-o','DisplayName','Reference : uncoded channel', 'LineWidth',2);hold all;grid on;
semilogy(E_B_OVER_N_0,hardBer,'-o','DisplayName','Reference : hard LDPC 5 maximum iterations', 'LineWidth',2);
for j = 1:length(MAXITER)
 semilogy(E_B_OVER_N_0,softBer(:,j),'-o','DisplayName',sprintf('%d maximum iterations', MAXITER(j)), 'LineWidth',2);hold all;grid on;
end
title('BER curves for decoders');
xlabel('E_b/N_0[dB]');
ylabel('BER');
legend('-DynamicLegend');
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
