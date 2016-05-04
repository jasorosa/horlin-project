function corrected = gardner(sampled, K)
    global TGARDNER;
    global AGARDNER;
    global FSGARDNER FM;
    osratio = FSGARDNER/FM;
    epsilon = zeros(ceil(size(sampled)./osratio));
    corrected = zeros(length(epsilon), 1);
    corrected(1) = sampled(1);
    for n = 1:length(epsilon)-1
        interpolation = interp1(1:osratio+1,sampled(osratio*(n-1)+1:osratio*n+1), [osratio/2+1 osratio+1] - epsilon(n), 'pchip');
        middle = interpolation(1);
        corrected(n+1) = interpolation(2);
        epsilon(n+1) = epsilon(n) + 2*K/FM*real(middle*(conj(corrected(n+1)) - conj(corrected(n))));
    end
    if TGARDNER
        figure;
        plot(epsilon./(FSGARDNER/FM));
        title('epsilon')
    end
    if AGARDNER
        f = figure; hold all;
        k = [0.1 1 2 5 10 20];
        for i = 1:length(k)
            epsilon = zeros(ceil(size(sampled)./osratio));
            useless = zeros(length(epsilon), 1);
            useless(1) = sampled(1);
            for n = 1:length(epsilon)-1
                interpolation = interp1(1:osratio+1,sampled(osratio*(n-1)+1:osratio*n+1), [osratio/2+1 osratio+1] - epsilon(n), 'pchip');
                middle = interpolation(1);
                useless(n+1) = interpolation(2);
                epsilon(n+1) = epsilon(n) + 2*k(i)/FM*real(middle*(conj(corrected(n+1)) - conj(useless(n))));
            end
            plot(epsilon./(FSGARDNER/FM), 'DisplayName', sprintf('K = %g', k(i)))
        end
        title('Convergence of the Gardner algorithm')
        xlabel('Symbol');
        ylabel('Epsilon estimation');
        legend('-DynamicLegend');
        set(findall(f,'-property','FontSize'),'FontSize',17);
        set(findall(f,'-property','FontName'),'FontName', 'Helvetica');
    end
end

