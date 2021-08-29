function c1 = FTCS(c0,dt,dx)
kappa = 0.1;
n = size(c0,2);
Rx = kappa*dt/(dx^2);
c1 = c0;
c1(2:n-1) = c0(2:n-1)+Rx*(c0(1:n-2)-2*c0(2:n-1)+c0(3:n));
end 