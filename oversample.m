function oversampled = oversample(original, f1, f2)
    ratio = ceil(f2/f1);
    oversampled = zeros(ratio*length(original), 1);
    for i = 1:length(original)
        oversampled(ratio*i+1:(i+1)*ratio) = ones(ratio, 1)*original(i);
    end
end
        