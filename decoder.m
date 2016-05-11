function infobits = decoder(coded, H, maxiter)
    cblksize = max(size(H));
    if mod(length(coded), cblksize) == 0
    iblksize = min(size(H));
    ratio = cblksize / iblksize;
    infobits = zeros(length(coded)/ratio, 1);
    for cblkstart = 1:cblksize:length(coded)
        cblk = coded(cblkstart:cblkstart+cblksize-1);
        oblk = tanner(cblk, H);
        iter = 1;
        while (~isequal(oblk, cblk)) && (iter < maxiter)
            cblk = oblk;
            oblk = tanner(cblk, H);
            iter = iter + 1;
        end
        infobits((cblkstart-1)/ratio+1:(cblkstart-1)/ratio+iblksize) = oblk(end-iblksize+1:end);
    end
    else
        fprintf('decoder: bad coded/H combination')
    end

end
