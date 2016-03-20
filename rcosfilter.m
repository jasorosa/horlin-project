function [h, f, fmax] = rcosfilter(beta,nbTaps,Tsym,Fs)
    h=zeros(nbTaps,1);
    fmax = Fs*(nbTaps-1)/(2*nbTaps);
    fdown = (1-beta)/(2*Tsym);
    fup = (1+beta)/(2*Tsym);
    f = linspace(-fmax, fmax, nbTaps);
    for i=1:length(f)
       if abs(f(i)) <= fdown
          h(i) = Tsym;
%           'Tsym'
       elseif abs(f(i)) > fup
           h(i) = 0;
%            '0'
       else
           h(i) = 0.5*Tsym*(1+cos(pi*(Tsym/beta)*(abs(f(i))-fdown)));
%            'f'
       end
    end
    
end