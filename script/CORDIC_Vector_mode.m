close all;
clear;
clc;

%Initialization
iter = 16;
x = zeros(iter+1, 1);
y = zeros(iter+1, 1);
z = zeros(iter+1, 1);
x(1) = 100;
y(1) = 200;
K = 0.607253;

for i=1:iter
    if y(i) >= 0
        d = -1;
    else
        d = 1;
    end
    x(i+1) = x(i) - d*y(i)*(2^-(i-1));
    y(i+1) = y(i) + d*x(i)*(2^-(i-1));
    z(i+1) = z(i) - d*atan(2^-(i-1));
end

x = vpa(x(17)*K, 10)    %Amplitude
y = vpa(y(17), 10)
z = vpa(rad2deg(z(17)), 10) %Phase