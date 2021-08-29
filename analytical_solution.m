function T = analytical_solution(time,r,N)
kappa = 0.1;
T = 2*r*time/pi + cos(r)*exp(-kappa*time);
for i = 1:N
    T = T + (1/(2*kappa*pi))*((-1)^i/i^3)*(1-exp(-4*kappa*i^2*time))*sin(2*i*r);
end 
end 

