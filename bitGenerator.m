function [ message ] = bitGenerator( number )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
length=number;

    for i=1:length
        value=rand(1);
        if(rand>=0.500)
            value=1;
        else
            value=0;
        end
       message(i)=value;
    end

end

