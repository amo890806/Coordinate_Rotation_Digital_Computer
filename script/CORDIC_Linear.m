function a = CORDIC_Linear(x1, y1, z1, mode, iter)
%mode 0: rotation mode, z0 [-1, 1]
%mode 1: vector mode, abs(y) <= abs(x)
    x = zeros(iter+1, 1);
    y = zeros(iter+1, 1);
    z = zeros(iter+1, 1);
    x(1) = x1;
    y(1) = y1;
    z(1) = z1;
    d = 0;
    for i=1:iter
        if mode == 0
            d = sign(z(i));
        else
            d = sign(-y(i));
        end
        x(i+1) = x(i);
        y(i+1) = y(i)+x(i)*d*2^(-i);
        z(i+1) = z(i)-d*2^(-i);
    end
    xn = x(iter+1);
    yn = y(iter+1);
    zn = z(iter+1);
    if mode == 0
        xt = x1;
        yt = y1+x1*z1;
        zt = 0;
    else
        xt = x1;
        yt = 0;
        zt = z1+y1/x1;
    end
    a = [xn, yn, zn, xt, yt, zt];
end