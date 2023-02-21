function [mean_er] = mean_error(y,y_est)
%% This function recieves two vectors and returns the mean error between
% this vectors
%% inputs:
% y - a data vector
% y_est - the estimation of the y vector
%% outputs:
% mean_er - the mean error between the two input vectors
m = length(y);
n = length(y_est);
if m~=n
    printf('Vectors should be the same length')
    return
end
m = length(y);
mean_er = 1/m*sum(abs(y-y_est));
end
