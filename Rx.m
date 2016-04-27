function message = Rx(signal, h_rrc, bps, pilotSymbol, varargin)
    global FM FS NTAPS NSYM K FC;
    global TDEMAPPING APILOT;
    MANUALCFOCORR = 0;
    dsmpEps = 0;

    if length(varargin) == 1
        df = varargin{1};
        MANUALCFOCORR = 1;
    elseif length(varargin) == 2
        df = varargin{1};
        MANUALCFOCORR = 1;
        dsmpEps = varargin{2};
    end

    %% Nyquist filer (rrc)
    oversampled = conv(signal, h_rrc); % len = len(h_rrc)+len(upsampledMes)-1
    oversampled = oversampled(NTAPS*FS/FM+1:end-(NTAPS*FS/FM)); % to get the right length after convolution we discard the RRCtaps-1 first samples
    %% downsampling
    if MANUALCFOCORR
        t = (0:length(oversampled)-1) ./ FS;
        cfo = exp((-1j*2*pi*df).* (t+t(NTAPS*ceil(FS/(2*FM)))));
        oversampled = oversampled .* cfo';
    end
    sampled = oversampled(1+floor(dsmpEps*FS/(2*FM)):ceil(FS/(2*FM)):end);
    %modulated = gardner(sampled, K);
    modulated = sampled(1:2:end);
    size(modulated)
    
    if ~isempty(pilotSymbol) && ~APILOT
        N = length(pilotSymbol);
        KWIN = 12;
        D = zeros(KWIN, NSYM-N+1);
        for k=1:KWIN
            for l = k:N-1
                D(k,:) = D(k,:) + ((conj(modulated(l:l+NSYM-N)) ... 
                    .*pilotSymbol(l)).*conj(conj(modulated(l-k+1:l-k+NSYM-N+1)) ... 
                    .*pilotSymbol(l-k+1))).';
            end
            D(k,:) = D(k,:)/(N-k);
        end
        %plot(sum(abs(D)));
        [~,est_n] = max(sum(abs(D)));
        
        est_cfo = 0;
        for k=1:KWIN
            est_cfo = est_cfo + angle(D(k,est_n))/(2*pi*k/FM);
        end
        est_n
        est_cfo = -est_cfo/KWIN
    end
    
    if APILOT
        PILOTSHFT = 33;
        modulated = [zeros(PILOTSHFT, 1); modulated];
        
        kWins = 6:2:14;
        pilotLengths = ceil((15:5:40)./bps);
        global dn dcfo;
        dn = zeros(length(kWins), length(pilotLengths));
        dcfo = zeros(length(kWins), length(pilotLengths));
        i = 1;
        for KWIN = kWins
            j = 1;
            for N = pilotLengths
                D = zeros(KWIN, NSYM-N+1);
                for k=1:KWIN
                    for l = k:N-1
                        currentPilotSymbol = pilotSymbol(1:N);
                        D(k,:) = D(k,:) + ((conj(modulated(l:l+NSYM-N)) ... 
                            .*currentPilotSymbol(l)).*conj(conj(modulated(l-k+1:l-k+NSYM-N+1)) ... 
                            .*currentPilotSymbol(l-k+1))).';
                    end
                    D(k,:) = D(k,:)/(N-k);
                end
                [~,est_n] = max(sum(abs(D)))

                est_cfo = 0;
                for k=1:KWIN
                    est_cfo = est_cfo + angle(D(k,est_n))/(2*pi*k/FM);
                end
                dn(i,j) = abs(est_n - 1 - PILOTSHFT);
                est_cfo = -est_cfo/KWIN;
                tmp = abs(20e-6*FC - est_cfo)/1e6;
                dcfo(i,j) = tmp;
                
                j = j + 1;
            end
            i=i+1;
        end
        dcfo
        dn       
    end
    
    
    
    modulated = modulated/sqrt(sum(abs(modulated).^2)/NSYM);
    if TDEMAPPING
        figure;
        scatter(real(modulated), imag(modulated)); % show the constellation
    end

    %input vector must be column vector
    message = demapping(modulated,bps,'qam'); % send message to demodulator function

end
