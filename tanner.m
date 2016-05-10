function oblk = tanner(cblk,H)
    error = mod(H*cblk,2);
    cblk = cblk';
    vote = cblk;
    for i=1:length(error)
        vote = vote + (xor(error(i),cblk)).*H(i,:);
    end
    oblk = (vote > sum(H,1)/2)';
end
