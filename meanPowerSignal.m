function Ps = meanPowerSignal(s)
    N=length(s);
    Ps=0;
    for n=1:N
        Ps=Ps+(s(n))^2;
    end
    Ps=Ps/N;
end
