function H = rcosfilter(beta, fm)
    global FS;
    nTaps = 1001;
    H = zeros(nTaps,1);

    for i=1:nTaps
       if ((i-1)/nTaps)*FS <= (1-beta)*fm/2
          H(i) = 1/fm;
       elseif ((i-1)/nTaps)*FS > (1+beta)*fm/2
           H(i) = 0;
       else
           tm = 1/fm;
           H(i) = 0.5*tm*(1+cos(pi*(tm/beta)*(((i-1)/nTaps)*FS-(1-beta)*fm/2)));
       end
    end
    figure;
    title('salut');plot(H);
end