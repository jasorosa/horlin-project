function mes = Rx( ReceivedMes, beta, Fm, Fs )
%UNTITLED3 Summary of this function goes here

%% Nyquist filer (rrc) 

sps = 40; % must match with multiplier
span = 160; % will have to be 16*sps+1
% G = rcosdesign(beta,span,sps,'sqrt'); % TODO !
RRCTaps = (span*sps)+1;
[H_rc, f, fmax] = rcosfilter(beta,RRCTaps, 1/Fm, Fs);
G = sqrt(H_rc*Fm);

dt = 1/(2*fmax);
t = (-(RRCTaps-1)/2:(RRCTaps-1)/2)*dt; % utility ?

h_rrc = ifftshift(ifft(G));

% plot(t,h_rrc);

% square root nyquist pulse filter , truncated to span symbols, each symbol period has sps samples
mesOversample=conv(G,ReceivedMes); % len = len(G)+len(upsampledMes)-1
mesOversample=mesOversample(RRCTaps:end-RRCTaps+1); % to get the right length after convolution we discard the RRCtaps-1 first samples

gg = conv(G,G);
plot(gg)


%% downsampling
downsampledMes = mesOversample(1:sps:end);

figure
scatter(real(downsampledMes), imag(downsampledMes)); % show the constellation

Nbps = 2; %Number of bit per symbol. Message must have n*Nbps elements
%input vector must be column vector
mes=demapping(downsampledMes,Nbps,'qam'); % send message to modulator function
%need to know the number of bit per symbol !!!!

end
