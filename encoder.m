function [coded, H] = encoder(H0, infobits)
    iblksize = min(size(H0));
    
    if mod(length(infobits), iblksize) == 0
    I = eye(iblksize);

    combili = mod(inv(H0(:,1:iblksize)),2);
    pPrim = mod(combili*H0(:,iblksize+1:end),2);

    H = [I pPrim];
    G = [pPrim' I];

    ratio = max(size(H0))/iblksize;
    coded = zeros(1, ratio*length(infobits));
    for blkbegin = 1:iblksize:length(infobits)
        coded(ratio*(blkbegin-1)+1:ratio*(blkbegin-1)+1+ratio*iblksize-1) = mod(infobits(blkbegin:blkbegin+iblksize-1)*G,2);
    end
    
    else
    fprintf('Bad H0/infobits combination')
    end
    
end
