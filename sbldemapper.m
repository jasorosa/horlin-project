function infobits = sbldemapper(received, H, maxiter)
    [m, n] = size(H);
    nblocks = length(received)/n;
    if mod(nblocks, 1) > 0
        fprintf('Bad arg size\n');
    else
    infobits = zeros(m,nblocks);
    cblocks = reshape(received,n,nblocks);
    chkindexes = zeros(m, max(sum(H,2)));
    for chknodei = 1:m
        varno = 1;
        for i = 1:n
            if H(chknodei,i) == 1
                chkindexes(chknodei, varno) = i;
                varno = varno + 1;
            end
        end
    end
    varindexes = zeros(n, max(sum(H,1)));
    for vari = 1:n
        chkno = 1;
        for i = 1:m
            if H(i, vari) == 1
                varindexes(vari, chkno) = i;
                chkno = chkno + 1;
            end
        end
    end
    for blki = 1:nblocks
        blk = cblocks(:,blki);
        variance = mean(min(abs(blk-1).^2,abs(blk+1).^2));
        obs = real(blk);
        lq = zeros(n, m);
        lr = zeros(m, n);
        lc = -2*obs/variance;
        for j = 1:m
            lq(:,j) = lc;
        end
        hard = lc < 0;
        currenterrors = sum(mod(H*hard, 2));
        doinggood = 1;
        iter = 1;
        while currenterrors > 0 && doinggood &&  iter <= maxiter
            previouserrors = currenterrors;
            for j = 1:m
                lr(j,:) = makelrj(lq(:,j), chkindexes(j,:));
            end
            for i = 1:n
                lq(i,:) = updatechknodes(lc(i),lr(:,i),varindexes(i,:));
            end
            newhard = (lc + sum(lr,1)') < 0;
            currenterrors = sum(mod(H*newhard, 2));
            doinggood = currenterrors <= previouserrors;
            if doinggood
                hard = newhard;
            end
            iter = iter + 1;
        end
        infobits(:,blki) = hard(n-m+1:end);       
    end
    infobits = reshape(infobits,m*nblocks,1);
end
