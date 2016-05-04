close all; clear all;

global FS FM FSGARDNER;
global AGARDNER;

AGARDNER = 1;

%general
NSYM = 1e3;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
BPS = 2; %Bits per symbol
NBITS = BPS*NSYM; %SE

%noise
E_B_OVER_N_0 = 10; %ratio of energy_bit/noise energy in dB (typ. 10)

%rrc filter
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter

%cfo
FC = 2e9; %for CFO
DF = 0;

%Gardner
FSGARDNER = 8*FM;
FS = 10*FSGARDNER;
DSMP = 40;
NEXP = 10;
K = [5 10]*1e-6;

h_rrc = rrcosfilter(BETA, FM, NTAPS);

f = figure; hold all;
for i = 1:length(K)
    for j = 1:NEXP
        sent = bitGenerator(NBITS);

        modulated = mapping(sent, BPS, 'qam');

        upsampled = upsample(modulated,FS/FM);
        out = conv(h_rrc, upsampled);

        signal = cfo(awgn(out, E_B_OVER_N_0, NBITS), DF*FC, 0);

        oversampled = conv(signal, h_rrc);
        oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM));

        gardnersampled = oversampled(1+DSMP:FS/FSGARDNER:end);

        [~, epsilon] = gardner(gardnersampled, K(i));
        if j == 1 && i == 1
            means = zeros(length(epsilon), length(K));
            stdv = zeros(length(epsilon), length(K));
        end
        means(:,i) = means(:,i) + epsilon;
        stdv(:, i) = stdv(:, i) + epsilon.^2;
    end
    means(:,i) = means(:,i)./NEXP;
    stdv(:,i) = sqrt(stdv(:,i)./NEXP - means(:,i) .^2);
    plot(means(:,i), 'DisplayName', sprintf('K = %g', K(i)))
    plot(means(:,i) + stdv(:,i));
    plot(means(:,i) - stdv(:,i));
end
title('Convergence of the Gardner algorithm')
xlabel('Symbol');
ylabel('Epsilon estimation');
legend('-DynamicLegend');
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');



modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);

received = demapping(modulated,BPS,'qam');
