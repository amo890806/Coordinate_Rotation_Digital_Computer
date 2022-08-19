close all;
clear;
clc;

%Initialization
iter = 16;
x = zeros(iter+1, 1);
y = zeros(iter+1, 1);
z = zeros(iter+1, 1);
y(1) = 0.607253;
x(1) = 0;
z(1) = pi/4;

for i=1:iter
    if z(i) >= 0
        d = 1;
    else
        d = -1;
    end
    x(i+1) = x(i) - d*y(i)*(2^-(i-1));
    y(i+1) = y(i) + d*x(i)*(2^-(i-1));
    z(i+1) = z(i) - d*atan(2^-(i-1));
end

cos_val = vpa(x(3)*2^16, 10)
sin_val = vpa(y(3)*2^16, 10)