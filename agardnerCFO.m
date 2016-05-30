close all; clear all;

global FS FM FSGARDNER;

%general
NSYM = 1e3;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
BPS = 2; %Bits per symbol
NBITS = BPS*NSYM; %SE

%noise
E_B_OVER_N_0 = 25; %ratio of energy_bit/noise energy in dB (typ. 10)

%rrc filter
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 20; %of the RRC filter

%cfo
FC = 2e9; %for CFO
DF = [0 10 50].*1e-6;


%Gardner
FSGARDNER = 8*FM;
FS = 16e6;
NEXP = 25;
K = .1;
DSMP = round(0.45*FS/FM);

%fig
DISPLAYINTERVALS = 25;

h_rrc = rrcosfilter(BETA, FM, NTAPS);

f = figure; hold all;

co =  [0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840;];
for i = 1:length(DF)
    for j = 1:NEXP
        sent = bitGenerator(NBITS);

        modulated = mapping(sent, BPS, 'qam');

        upsampled = upsample(modulated,FS/FM);
        out = conv(h_rrc, upsampled);

        signal = cfo(awgn(out, E_B_OVER_N_0, NBITS), DF(i)*FC, 0);

        oversampled = conv(signal, h_rrc);
        oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM));

        gardnersampled = oversampled(1+DSMP:FS/FSGARDNER:end);

        [~, epsilon] = gardner(gardnersampled, K);
        smperror = (DSMP - epsilon.*FS/FM)./FS;
        if j == 1 && i == 1
            means = zeros(length(smperror), length(DF));
            stdv = zeros(length(smperror), length(DF));
        end
        means(:,i) = means(:,i) + smperror;
        stdv(:, i) = stdv(:, i) + smperror.^2;
    end
    means(:,i) = means(:,i)./NEXP;
    stdv(:,i) = sqrt(stdv(:,i)./NEXP - means(:,i) .^2);
    c = co(i,:);
    p = plot(1:DISPLAYINTERVALS:length(means),means(1:DISPLAYINTERVALS:end,i), 'DisplayName', sprintf('CFO = %2.0fppm', DF(i)*1e6), 'color',c,'linestyle', '-', 'marker', 'o');
    p = plot(1:DISPLAYINTERVALS:length(means), means(1:DISPLAYINTERVALS:end,i) + stdv(1:DISPLAYINTERVALS:end,i), 'color', c, 'LineStyle', '--');
    set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    p = plot(1:DISPLAYINTERVALS:length(means), means(1:DISPLAYINTERVALS:end,i) - stdv(1:DISPLAYINTERVALS:end,i), 'color', c, 'LineStyle', '--');
    set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
title('Robustness of Gardner to CFO')
xlabel('Symbol');
ylabel('Time error (mean \pm stdv)');
legend('-DynamicLegend');
set(findall(f,'-property','FontSize'),'FontSize',17);
set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
grid on;
ylim([-inf 5e-7]);

modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);

received = demapping(modulated,BPS,'qam');
