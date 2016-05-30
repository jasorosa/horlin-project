function [nHat, cfoHat] = frameAcq(pilotSymbol, modulated, N, K)
    global FM;
    global TFRAME;
    D = zeros(K, length(modulated));
    for k=1:K-1
        for l = k:N-1
            next = padto((conj(modulated(l+1:end)).*pilotSymbol(l+1)), [length(modulated),1]);
            next = next.*padto(conj(conj(modulated(l-k+1:end)).*pilotSymbol(l-k+1)), [length(modulated),1]);
            next = next.';
            D(k+1,:) = D(k+1,:) + next;
        end
        D(k+1,:) = D(k+1,:)/(N-k);
    end
    D = D(:,1:end-N+1);
    if TFRAME
        f= figure;
        plot(sum(abs(D)));
        xlim([-50 inf]);
        ylabel('\Sigma_k |D|');
        xlabel('n');
        title('Average over k of the output metric')
        set(findall(f,'-property','FontSize'),'FontSize',17);
        set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
        grid on; box on;
    end
    [~,nHat] = max(sum(abs(D)));

    cfoHat = 0;
    for k=1:K
        cfoHat = cfoHat + angle(D(k,nHat))/(2*pi*k/FM);
    end
    cfoHat = -cfoHat/K;
end
