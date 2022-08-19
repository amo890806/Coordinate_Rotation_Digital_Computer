close all;
clear;
clc;

%Initialization
iter = 16;
theta = zeros(iter, 1);
cos_val = zeros(iter, 1);
K = zeros(iter, 1);
K_inv = zeros(iter, 1);

for i=1:iter
    theta(i) = atan(2^-(i-1));
    cos_val(i) = cos(theta(i));
    if(i == 1)
        K(i) = cos_val(i);
    else
        K(i) = K(i-1)*cos_val(i);
    end
    K_inv(i) = 1/K(i);
end

theta = vpa(rad2deg(theta), 10)
cos_val = vpa(cos_val, 10)
K = vpa(K, 10)
K_inv = vpa(K_inv, 10)