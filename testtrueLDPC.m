close all; clear all;

global FS FM FSGARDNER;
global TFILTERGEN TMAPPING TDEMAPPING TRX TGARDNER;

TFILTERGEN = 0;
TRX = 1;
TDEMAPPING = 1;
TMAPPING = 0;
TGARDNER = 1;

%general
NSYM = 1024;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
FS = 16*FM;
BPS = 2; %Bits per symbol
NBITS = BPS*NSYM; %SE

%noise
E_B_OVER_N_0 = 6; %ratio of energy_bit/noise energy in dB (typ. 10)

%rrc filter
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter

%cfo
FC = 2e9; %for CFO
DF = 0;

%Gardner
FSGARDNER = 8*FM;
K = .05;
DSMP = 4;

%frame acquisition
N = 40;
KWIN = 12;

%LDPC
IBLKSIZE = 128;
RATIO = 2;
CBLKSIZE = RATIO*IBLKSIZE;
MAXITER = 101;
H0 = makeLDPC(IBLKSIZE, CBLKSIZE, 0, 1, 3);

infobits = bitGenerator(NBITS);
[sent, H] = makeParityChk(infobits(1:IBLKSIZE), H0, 0);
sent = [sent;infobits(1:IBLKSIZE)];
for blkstart = IBLKSIZE+1:IBLKSIZE:NBITS
    [checkbits, ~] = makeParityChk(infobits(blkstart:blkstart+IBLKSIZE-1), H0, 0);
    sent = [sent;checkbits;infobits(blkstart:blkstart+IBLKSIZE-1)];
end

h_rrc = rrcosfilter(BETA, FM, NTAPS);
pilotSymbol = mapping(sent(1:N), BPS, 'qam');

modulated = mapping(sent, BPS, 'qam');
if TMAPPING
   figure;
   scatter(real(modulated), imag(modulated));
end

upsampled = upsample(modulated,FS/FM);

out = conv(h_rrc, upsampled); % len = len(h_rrc)+len(upsampledMes)-1

signal = cfo(awgn(out, E_B_OVER_N_0, NBITS), DF*FC, 0);

oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples

gardnersampled = oversampled(1+DSMP:FS/FSGARDNER:end);

modulated = gardner(gardnersampled, K);

%[nHat cfoHat] = frameAcq(pilotSymbol, modulated, N, KWIN);

if TDEMAPPING
    figure;
    scatter(real(modulated), imag(modulated)); % show the constellation
end

%input vector must be column vector
received = demapping(modulated,BPS,'qam'); % send message to demodulator function
rcvinfobits = decoder(received,H, MAXITER);

if TRX
    figure;
    fprintf('uncoded errors: %d, coded errors: %d\n', sum(abs(sent-received)), sum(abs(infobits - rcvinfobits)))
    stem(abs(infobits - rcvinfobits));    
end
