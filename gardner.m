function [corrected] = gardner(sampled, K)
    global TGARDNER FM;
    epsilon = zeros(ceil(length(sampled)/2), 1);
    corrected = zeros(length(epsilon), 1);
    corrected(1) = sampled(1);
    for n = 1:length(epsilon)-1
        interpolation = interp1(1:3,sampled(2*n-1:2*n+1), (1:3)+epsilon(n), 'cubic');
        corrected(n) = interpolation(1);
        middle = interpolation(2);
        corrected(n+1) = interpolation(3);
        epsilon(n+1) = epsilon(n) + 2*K/FM*real(middle*(conj(corrected(n+1)) - conj(corrected(n))));
    end
    if TGARDNER
        figure;
        plot(epsilon);
        length(epsilon)
        title('epsilon')
    end
end

