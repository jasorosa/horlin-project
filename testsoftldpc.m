close all; clear all;

global FS FM;
global TFILTERGEN TMAPPING TDEMAPPING TRX;

TFILTERGEN = 0;
TRX = 1;
TDEMAPPING = 1;
TMAPPING = 1;

%general
NSYM = 2^13;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
FS = 5*FM;
BPS = 1; %Bits per symbol
NBITS = BPS*NSYM; %SE

%noise
E_B_OVER_N_0 = 7; %ratio of energy_bit/noise energy in dB (typ. 10)

%rrc filter
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter


%LDPC
IBLKSIZE = 128;
RATIO = 2;
CBLKSIZE = RATIO*IBLKSIZE;
MAXITER = 5;
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
if TMAPPING
   figure;
   scatter(real(modulated), imag(modulated));
end

upsampled = upsample(modulated,FS/FM);

out = conv(h_rrc, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

signal = awgn(out, E_B_OVER_N_0, NBITS);

oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples

modulated = oversampled(1:FS/FM:end);

if TDEMAPPING
    figure;
    scatter(real(modulated), imag(modulated)); % show the constellation
end

%input vector must be column vector
received = demapping(modulated, BPS, 'pam');
rcvinfobits = sbldemapper(modulated, H, MAXITER);

if TRX
    figure;
    stem(abs(infobits - rcvinfobits));
    fprintf('uncoded errors: %d, coded errors: %d\n', sum(abs(sent-received)), sum(abs(infobits - rcvinfobits)))
end
