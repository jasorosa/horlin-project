function corrected = gardner(sampled, K)
    global TGARDNER FSGARDNER FM;
    osratio = FSGARDNER/FM
    epsilon = zeros(ceil(size(sampled)./osratio));
    corrected = zeros(length(epsilon), 1);
    corrected(1) = sampled(1);
    for n = 1:length(epsilon)-1
        interpolation = interp1(1:osratio+1,sampled(osratio*(n-1)+1:osratio*n+1), [osratio/2+1 osratio+1] + epsilon(n), 'pchip');
        middle = interpolation(1);
        corrected(n+1) = interpolation(2);
        epsilon(n+1) = epsilon(n) - 2*K/FM*real(middle*(conj(corrected(n+1)) - conj(corrected(n))));
    end
    if TGARDNER
        figure;
        plot(epsilon);
        title('epsilon')
    end
end

