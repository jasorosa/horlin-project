clear; close all;

global NBITS NSYM BETA FS FM E_B_OVER_N_0 NTAPS K FC;
global TFILTERGEN TMAPPING TDEMAPPING...
    TRX TGARDNER;
global ANYQUIST ABER ACFOISI ARAWCFO ASMPSHIFT APILOT;

TEST = 1;
TFILTERGEN = TEST && 0;
TRX = TEST && 0;
TDEMAPPING = TEST && 0;
TMAPPING = TEST && 0;
TGARDNER = TEST && 0;

ASSIGNMENT = 1;
ANYQUIST = ASSIGNMENT && 0;
ABER = ASSIGNMENT && 0;
ACFOISI = ASSIGNMENT && 0;
ARAWCFO = ASSIGNMENT && 0;
ASMPSHIFT = ASSIGNMENT && 0;
APILOT = ASSIGNMENT && 1;

FC = 2e9; %for CFO

NSYM = 1e3;
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 100; %of the RRC filter
FS = 100e6;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
K = 0;

E_B_OVER_N_0 = 10; %ratio of energy_bit/noise energy in dB (typ. 10)

sent = bitGenerator(NBITS);
h_rrc = rrcosfilter(BETA,FM);

if TEST
    BPS = 2; %Bits per symbol
    NBITS = BPS*NSYM; %SE

    pilotSymbol = mapping(sent(1:40), BPS, 'qam');
    
    out = Tx(sent, h_rrc, BPS);
    signal = cfo(awgn(out, E_B_OVER_N_0), 20e-6*FC, 0);
    received = Rx(signal, h_rrc, BPS, pilotSymbol, 0, 0);
end

if TRX
    figure;
    stem( abs(sent - received));
end

if ABER
    f = figure;

    bps = 2:2:8;
    ebn0 = -10:.5:25;
    bers = zeros(length(bps),length(ebn0));
    for i = 1:length(bps)
        NBITS = bps(i)*NSYM;
        sent = bitGenerator(NBITS);
        for j = 1:length(ebn0)
            received = Rx(awgn(Tx(sent, h_rrc, bps(i)), ebn0(j)), h_rrc, bps(i));
            bers(i,j) = sum(abs(received-sent))/NBITS;
        end
        semilogy(ebn0,bers(i,:),'-o','DisplayName',sprintf('%d-QAM', 2^bps(i)), 'LineWidth',2);hold all;grid on;
    end
    title('BER curves for different QAMs');
    xlabel('SNR per bit [dB]');
    ylabel('BER');
    legend('-DynamicLegend');
    set(findall(f,'-property','FontSize'),'FontSize',17);
    set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
end

if ACFOISI
    f = figure;

    BPS = 4; %Bits per symbol
    NBITS = BPS*NSYM; %SE

    dsmpEps = [0 2 10 25 40] .* (1e-6*FC);
    ebn0 = -10:.5:25;
    bers = zeros(length(dsmpEps),length(ebn0));
    sent = bitGenerator(NBITS);
    for i = 1:length(dsmpEps)
        for j = 1:length(ebn0)
            signal = cfo(awgn(Tx(sent, h_rrc, BPS), ebn0(j)), dsmpEps(i), 0);
            received = Rx(signal,h_rrc, BPS, dsmpEps(i));
            bers(i,j) = sum(abs(received-sent))/NBITS;
        end
        semilogy(ebn0,bers(i,:),'-o','DisplayName',sprintf('CFO = %d ppm', dsmpEps(i)/FC * 1e6), 'LineWidth',2);hold all;grid on;
    end
    title('Impact of perfectly compensated (ISI only) CFO on BER');
    xlabel('SNR per bit [dB]');
    ylabel('BER');
    legend('-DynamicLegend');
    set(findall(f,'-property','FontSize'),'FontSize',17);
    set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
end

if ARAWCFO

end

if ASMPSHIFT
    f = figure;

    BPS = 2; %Bits per symbol
    NBITS = BPS*NSYM; %SE

    dsmpEps = linspace(0,0.5,8);
    ebn0 = -10:.5:25;
    bers = zeros(length(dsmpEps),length(ebn0));
    sent = bitGenerator(NBITS);
    for i = 1:length(dsmpEps)
        for j = 1:length(ebn0)
            signal = awgn(Tx(sent, h_rrc, BPS), ebn0(j));
            received = Rx(signal,h_rrc, BPS, 0, dsmpEps(i));
            bers(i,j) = sum(abs(received-sent))/NBITS;
        end
        semilogy(ebn0,bers(i,:),'-o','DisplayName',sprintf('Epsilon = %g', dsmpEps(i)), 'LineWidth',2);hold all;grid on;
    end
    title('Impact of sample time shift on BER');
    xlabel('SNR per bit [dB]');
    ylabel('BER');
    legend('-DynamicLegend');
    set(findall(f,'-property','FontSize'),'FontSize',17);
    set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
end
