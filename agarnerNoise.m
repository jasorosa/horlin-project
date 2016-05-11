close all; clear all;

global FS FM FSGARDNER;

%general
NSYM = 1e4;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
BPS = 2; %Bits per symbol
NBITS = BPS*NSYM; %SE

%noise
EBN0 = 0:.5:16; %ratio of energy_bit/noise energy in dB (typ. 10)

%rrc filter
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter

%cfo
FC = 2e9; %for CFO


%Gardner
FSGARDNER = 8*FM;
FS = 16e6;
K = .05;
DSMP = round(0.45*FS/FM);


h_rrc = rrcosfilter(BETA, FM, NTAPS);

f = figure; hold all;
stdv = [];
bad = [];
for i = 1:length(EBN0)
        fprintf('noise:%d/%d\n',i,length(EBN0));
        sent = bitGenerator(NBITS);

        modulated = mapping(sent, BPS, 'qam');

        upsampled = upsample(modulated,FS/FM);
        out = conv(h_rrc, upsampled);

        signal = awgn(out, EBN0(i), NBITS);

        oversampled = conv(signal, h_rrc);
        oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM));

        gardnersampled = oversampled(1+DSMP:FS/FSGARDNER:end);

        [~, epsilon] = gardner(gardnersampled, K);
        smperror = (DSMP - epsilon.*FS/FM)./FS;
        next = sqrt(var(smperror)); 
        if i == 1 || (next < stdv(end) && next> stdv(end)/4)
            stdv(end+1) = next;
            disp coucou
        else
            next
            stdv(end)
            bad(end+1) = i;
        end
end
for i = bad(end:-1:1)
    EBN0 = [EBN0(1:i-1) EBN0(i+1:end)];
end
plot(EBN0,stdv);
title('Impact of noise on Gardner')
xlabel('E_b/N_0');
ylabel('Time error stdev');
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
grid on;

modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);

received = demapping(modulated,BPS,'qam');
