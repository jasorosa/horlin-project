function mesToSend = Tx(message)

    global BETA FM FS BPS;

    %input vector must be column vector
    modulated=mapping(message, BPS, 'qam');
    
    %% upsampling
    upsampled = oversample(modulated, FM, FS);
    
    %% Nyquist filer (rrc)     
    H_rc = rcosfilter(BETA, FM);
    H_rrc = sqrt(H_rc*FM); %square root + normalization
    figure;
    plot(H_rrc)
    h_rrc = ifftshift(ifft(H_rrc));


    % figure
    % plot(t,h_rrc)

    mesToSend=conv(h_rrc,upsampled); % len = len(G)+len(upsampledMes)-1

end

% taps of the filter : time extension & frequency resolution
% RRCTaps = length(H(f))
% Fax=Fs/2
% f=linspace(-fmax,fmax,RRCTaps)
% may need to normalize H to get impulse =1 at t=0
% Delta_T = 1/2fmax
% t=((-RRCTaps-1)/2:(RRCTaps-1)/2)*delta_t
% use ifft ifftshift !


% length(conv(vec1)) !=length(vec1) !!
% use mlf2pdf