function [h, f, fmax] = rcosfilter(beta, nTaps)
    
    global FM FS;
    tm = 1/FM;
    h=zeros(nTaps,1);
    fmax = FS*(nTaps-1)/(2*nTaps);
    fdown = (1-beta)/(2*tm);
    fup = (1+beta)/(2*tm);
    f = linspace(-fmax, fmax, nTaps);
    for i=1:length(f)
       if abs(f(i)) <= fdown
          h(i) = tm;
%           'Tsym'
       elseif abs(f(i)) > fup
           h(i) = 0;
%            '0'
       else
           h(i) = 0.5*tm*(1+cos(pi*(tm/beta)*(abs(f(i))-fdown)));
%            'f'
       end
    end
    
end