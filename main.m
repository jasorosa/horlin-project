clear; close all;

global NBITS NSYM BETA FS FM E_B_OVER_N_0 NTAPS;
global TEST TESTFILTERGEN TESTTX TESTMAPPING TESTDEMAPPING...
    TESTRX;
global ANYQUIST ABER ACFOISI;

TEST = 0;
TESTFILTERGEN = 0;
TESTTX = 0;
TESTRX = 1;
TESTDEMAPPING = 1;
TESTMAPPING = 0;

ASSIGNMENT = 1;
ANYQUIST = ASSIGNMENT && 0;
ABER = ASSIGNMENT && 1;
ACFOISI = ASSIGNMENT && 0;

BPS = 4; %Bits per symbol
NSYM = 1e7;
NBITS = BPS*NSYM; %SE
BETA = 0.3; %Rolloff factor of the RRC filter
NTAPS = 100; %of the RRC filter
FS = 10e6;
FM = 1e6; %symbol frequency, also defines the cutoff frequency for the rrc filters
FC = 2e9; %for CFO
E_B_OVER_N_0 = 10; %ratio of energy_bit/noise energy in dB (typ. 10)

sent = bitGenerator(NBITS);
h_rrc = rrcosfilter(BETA,FM);

received = Rx(cfo(awgn(Tx(sent, h_rrc, BPS), E_B_OVER_N_0), FC*10e-6, 0), h_rrc, BPS, FC*10e-6);

if TEST && TESTRX
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

    df = [0 2 6 10 40] .* (1e-6*FC);
    ebn0 = 0:.5:25;
    bers = zeros(length(df),length(ebn0));
    sent = bitGenerator(NBITS);
    for i = 1:length(df)
        for j = 1:length(ebn0)
            signal = cfo(awgn(Tx(sent, h_rrc, BPS), ebn0(j)), df(i), 0);
            received = Rx(signal,h_rrc, BPS, df(i));
            bers(i,j) = sum(abs(received-sent))/NBITS;
        end
        semilogy(ebn0,bers(i,:),'-o','DisplayName',sprintf('CFO = %d ppm', df(i)/FC * 1e6), 'LineWidth',2);hold all;grid on;
    end
    title('Impact of CFO on BER');
    xlabel('SNR per bit [dB]');
    ylabel('BER');
    legend('-DynamicLegend');
    set(findall(f,'-property','FontSize'),'FontSize',17);
    set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
end
