function y = cfo(u, df, dphi)
    global FS;
    y = u .* (exp((1j*2*pi).*((df*1/FS).*(0:length(u)-1) + dphi)))';
end
