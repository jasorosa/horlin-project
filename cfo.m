function y = cfo(u, df, dphi)
    global FS;
    t = (0:length(u)-1)./FS;
    osc = exp(1j.* (2*pi*df .* t + dphi));
    y = u .* osc';
end
