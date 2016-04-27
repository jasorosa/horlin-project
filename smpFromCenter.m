function sampled = smpFromCenter(u,downsampling_ratio)
    c = ceil(length(u)/2);
    sampled = [u(c-downsampling_ratio:-downsampling_ratio:1); u(c:downsampling_ratio:end)];
end
