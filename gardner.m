function epsilon = gardner(eps_init, K, y, y_before)
    epsilon = eps_init + K * real((y(1)+y(2))/2 * (conj(y(2))-conj(y_before);
end

