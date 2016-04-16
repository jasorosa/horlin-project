function sampled = smpFromCenter(u,downsampling_ratio)
    c = ceil(length(u)/2);
    sampled = [u(c-downsampling_ratio-1:-downsampling_ratio-1:1); u(c:downsampling_ratio+1:end)];
end
