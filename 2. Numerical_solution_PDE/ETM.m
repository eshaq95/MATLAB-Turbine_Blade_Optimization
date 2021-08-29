function[T_total] = ETM(Nx,dt,tstop)
    kappa = 0.1;
    N = Nx;
    dx = 0.5*pi/(Nx-1);
    x = 0.0:dx:0.5*pi-dx;
    T_total =[];
    fprintf('The grid contains %3i nodes (dx = %.3f).\n',N-1,dx);
    
    T = cos(x);
    
    for time = dt:dt:tstop
        T(1) = exp(-kappa*time);
        T(Nx) = time;
        T_total = [T_total;T];
        T = FTCS(T,dt,dx);
        
    end 
    T_total = [T_total:T];
end     