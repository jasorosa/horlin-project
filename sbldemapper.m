function infobits = sbldemapper(received, H, maxiter)
    [m, n] = size(H);
    nblocks = length(received)/n;
    if mod(nblocks, 1) > 0
        fprintf('Bad arg size\n');
    else
    infobits = zeros(m,nblocks);
    cblocks = reshape(received,n,nblocks);
    for blki = 1:nblocks
        blk = cblocks(:,blki);
        variance = mean(min(abs(blk-1).^2,abs(blk+1).^2));
        obs = real(blk);
        LQi = -2*obs/variance;
        hard = LQi < 0;
        infobits(:,blki) = hard(n-m+1:end);       
    end
    infobits = reshape(infobits,m*nblocks,1);
end
