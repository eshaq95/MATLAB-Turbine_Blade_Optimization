clear;
Nx = 20;

tstop = 4;
a = 0;
b = 0.5*pi;
kappa = 0.1;
dx = (b-a)/(Nx-1);
x = a:dx:b;
dt=dx^2/0.2;
fprintf('dt =%.3f seconds\n',dt);
fprintf ( 'The grid contains %3i nodes (dx= %.3f ) .\n ', Nx+1, dx) ; 
T = zeros(1,Nx);
for i = 1:Nx
    T(i) = cos(dx*(i -1));
end 
T_total =  ETM(Nx,dt,tstop);
T_analytical = [analytical_solution(0,x,500)];
for time=dt : dt : tstop 
     % Set the boundary conditions 
      T(1) = exp(-kappa*time); % Dirichlet 
      T(Nx) = time; % Dirichlet
T_analytical = [T_analytical; analytical_solution(time,x,500)];
T_total = [T_total;T];
T = FTCS(T,dt,dx);
end
T_total = [T_total;T];
time = 0:dt:tstop;

figure(1);
surf(x,time,T_analytical,'edgecolor','none');
title('Analytical surface')
xlabel('x')
ylabel('t')
zlabel('u(x,t)');

figure(2);
surf(x,time,T_total,'edgecolor','none');
title('Numerical surface')
xlabel('x')
ylabel('t')
zlabel('u(x,t)');

figure(3);
surf(x,time,T_total-T_analytical,'edgecolor','none');
title('Numerical surface minus analytical')
xlabel('x')
ylabel('t')
zlabel('u(x,t)');

figure(4)
[C,uval] = contour(x,time,T_total);
contour(x,time,T_total,'ShowText','on')
title('Numerical contour')
xlabel('x');
ylabel('t');

figure(5)
[C,uval] = contour(x,time,T_total-T_analytical);
contour(x,time,T_total-T_analytical,'ShowText','on');
title('Numerical minus analytical contour')
xlabel('x');
ylabel('t');
zlabel ( 'u(x,t )');

