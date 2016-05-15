function lrj = makelrj(lqj, chkidxj)
    if chkidxj(end) > 0
        realength = length(chkidxj);
    else
        realength = find(chkidxj == 0, 1)-1;
    end
    signprod = 1;
    minfrom = zeros(realength,1);
    for i = 1:realength
        signprod = signprod*sign(lqj(chkidxj(i)));
        minfrom(i) = abs(lqj(chkidxj(i)));
    end
    minfrom = sort(minfrom);
    minalpha = minfrom(1);
    lrj = zeros(length(lqj),1);
    for i = 1:realength
        var = lqj(chkidxj(i));
        tmpsign = signprod/sign(var);
        if var == minalpha
            lrj(chkidxj(i)) = tmpsign*minfrom(2);
        else
            lrj(chkidxj(i)) = tmpsign*minalpha;
        end
    end
end
