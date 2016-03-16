function mes = Rx( ReceivedMes )
%UNTITLED3 Summary of this function goes here

%% Nyquist filer (rrc) 
beta = 0.25;
sps = 4; % must match with multiplier
span = 16; % will have to be 16*sps+1
G = rcosdesign(beta,span,sps,'sqrt'); % TODO !
RRCtaps=length(G); 
% square root nyquist pulse filter , truncated to span symbols, each symbol period has sps samples
mesOversample=conv(G,ReceivedMes); % len = len(G)+len(upsampledMes)-1
mesOversample=mesOversample(RRCtaps:end-RRCtaps+1); % to get the right length after convolution we discard the RRCtaps-1 first samples
% gg = conv(G,G);
% plot(gg)


%% downsampling
downsampledMes = mesOversample(1:sps:end);

figure
scatter(real(downsampledMes), imag(downsampledMes)); % show the constellation

Nbps = 2; %Number of bit per symbol. Message must have n*Nbps elements
%input vector must be column vector
mes=demapping(downsampledMes,Nbps,'qam'); % send message to modulator function
%need to know the number of bit per symbol !!!!

end
