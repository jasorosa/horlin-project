function [message] = bitGenerator()
    global NBITS;
    message = randi([0 1], NBITS, 1);
end

