function lqi = updatechknodes(obsi,lri,varidxi)
    if varidxi(end) > 0
        realength = length(varidxi);
    else
        realength = find(varidxi == 0,1)-1;
    end

    lqi = zeros(1,length(lri));
    lrisum = 0;
    for idx = varidxi(1:realength)
        lrisum = lrisum + lri(idx);
    end
    for idx = varidxi(1:realength)
        lqi(idx) = obsi + lrisum - lri(idx);
    end
end
