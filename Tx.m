function mesToSend = Tx( mess, beta, Fm, Fs )
%UNTITLED3 Summary of this function goes here
   
message=mess;
Nbps = 2; %Number of bit per symbol. Message must have n*Nbps elements
%input vector must be column vector
modulated=mapping(message.',Nbps,'qam'); % send message to modulator function
%need to know the number of bit per symbol !!!!

%% upsampling
sps = 4; % multiplier factor must match with sps

upsampledMes = upsample(modulated,sps);

%% Nyquist filer (rrc) 

% sps = 4; % must match with multiplier
span = 16; % will have to be 16*sps+1
RRCTaps = (span*sps)+1;
%G = rcosdesign(beta,span,sps,'sqrt'); % square root nyquist pulse filter , truncated to span symbols, each symbol period has sps samples

[H_rc, f, fmax] = rcosfilter(beta,RRCTaps,1/Fm,Fs);
G = sqrt(H_rc*Fm); % square root + normalization ?

% plot(f,G)

dt = 1/(2*fmax);
t = (-(RRCTaps-1)/2:(RRCTaps-1)/2)*dt; % utility ?

h_rrc = ifftshift(ifft(G));


% figure
% plot(t,h_rrc)

mesToSend=conv(G,upsampledMes); % len = len(G)+len(upsampledMes)-1

end

% taps of the filter : time extension & frequency resolution
% RRCTaps = length(H(f))
% fmax=Fs/2
% f=linspace(-fmax,fmax,RRCTaps)
% may need to normalize H to get impulse =1 at t=0
% Delta_T = 1/2fmax
% t=((-RRCTaps-1)/2:(RRCTaps-1)/2)*delta_t
% use ifft ifftshift !


% length(conv(vec1)) !=length(vec1) !!
% use mlf2pdf