function corrected = gardner(sampled, K)
     global TGARDNER NSYM FM;
%     epsilon = zeros(ceil(length(sampled)/2), 1);
%     corrected = zeros(length(epsilon), 1);
%     corrected(1) = sampled(1);
%     for n = 1:length(epsilon)-1
%         interpolation = interp1(1:3,sampled(2*n-1:2*n+1), (2:3)-epsilon(n), 'PCHIP');
%         middle = interpolation(1);
%         corrected(n+1) = interpolation(2);
%         epsilon(n+1) = epsilon(n) + 2*K*real(middle*(conj(corrected(n+1)) - conj(corrected(n))));
%     end
    eps0=0; %initial error e0
    %t0 = timeshift = eps0*T
    %eps0 is in [-1/2,1/2]
    y_init = 0;
    T = 1/FM;
    eps_vec = zeros(1,NSYM);
    corrected = sampled(1);
    for n = 1:NSYM-1
        x = (n-1)*T:T/2:n*T; %length M+1
        y = sampled(2*n-1:2*n+1);
        c_half = (((n*2)-1)/2-eps0)*T; %+ or -?
        c_inter = (n-eps0)*T;
        y_half = interp1(x,y ,c_half , 'PCHIP'); % interpolate
        y_inter = interp1(x,y,c_inter,'PCHIP');
        compensated_fact = 2*K*real(y_half *(conj(y_inter) - conj(y_init))); % factor 2 ??
        y_init = y_inter;
        corrected(end+1) = y_inter;
        eps0 = eps0 + compensated_fact;
        eps_vec(n+1) = eps0;
    end
    corrected  = corrected';
    if TGARDNER
        figure;
        plot(eps_vec);
        title('epsilon')
    end
end

