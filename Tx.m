function mesToSend = Tx(message)

    global BETA FM BPS;

    %input vector must be column vector
    modulated=mapping(message, BPS, 'qam'); % send message to modulator function
    %need to know the number of bit per symbol !!!!

    %% upsampling
    sps = 40; % multiplier factor must match with sps

    upsampledMes = upsample(modulated,sps);

    %% Nyquist filer (rrc) 

    % sps = 4; % must match with multiplier
    span = 160; % will have to be 16*sps+1
    RRCTaps = (span*sps)+1;
    %G = rcosdesign(beta,span,sps,'sqrt'); % square root nyquist pulse filter , truncated to span symbols, each symbol period has sps samples

    [H_rc, ~, fmax] = rcosfilter(BETA, RRCTaps);
    G = sqrt(H_rc*FM); % square root + normalization ?

    % plot(f,G)

    dt = 1/(2*fmax);
    t = (-(RRCTaps-1)/2:(RRCTaps-1)/2)*dt; % utility ?

    h_rrc = ifftshift(ifft(G));


    % figure
    % plot(t,h_rrc)

    mesToSend=conv(h_rrc,upsampledMes); % len = len(G)+len(upsampledMes)-1

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