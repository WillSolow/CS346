% hw3_ex2_whsolo_sorhom.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% HW3 - HH simulations

% This code simulates the HH Model with the Na-K pump, graphing V, m,
% n, and h with respect to time

% TO RUN: Press F5

% simulation length and change in time
sim_length = 3;
dt = .001;
num_iterations = sim_length/dt;

% Initializing constants
I_max = 15;
I = 0;
C_M = .1;

% initial voltage and gating probabilities
V_init = -65;
n_init = .317;
m_init = .05;
h_init = .6;

% Gating constants. Controls when the gates open and close based on the
% voltage
Na_open = -55;
Na_close = 49.3;
K_open = 49.3;

% default is that both channels start as closed - 0 is closed, 1 is open
% used to keep track if the voltage gated channels are open to control
% current
Na_O = 0;
K_O = 0;

% displacements from equilibrium potential K: potassium, Na: sodium, L: leakage
% used in calculating the currents of K, Na, and L
V_K = -77;
V_Na = 50;
V_L = -54.4;

% conductance constants K: potassium, Na: sodium, L: leakage
% used in caculating the currents of K, Na, and L
g_K  = 36;
g_Na = 120;
g_L  = .3;

% assign initial values to voltage and gate constants
t(1) = 0;
V(1) = V_init;
n(1) = n_init;
m(1) = m_init;
h(1) = h_init;

% calculating opening and closing rate constants
% used in calculating the probablities of a gate being open for 
% n, m, and h, the gates of K, Na, and L
a_n = @(V) .01  * (V+55) / (1 - exp(-(V+55) / 10));
a_m = @(V) .1   * (V+40) / (1 - exp(-(V+40) / 10));
a_h = @(V) .07  *               exp(-(V+65) / 20) ;
b_n = @(V) .125 *               exp(-(V+65) / 80) ;
b_m = @(V) 4    *               exp(-(V+65) / 18) ;
b_h = @(V) 1             / (1 + exp(-(V+35) / 10));

% calculating rate of change of n, m, and h (gating variables)
dNdt = @(V, n, m, h) a_n(V) * (1-n) - b_n(V) * n;
dMdt = @(V, n, m, h) a_m(V) * (1-m) - b_m(V) * m;
dHdt = @(V, n, m, h) a_h(V) * (1-h) - b_h(V) * h;

% calculating currents of K, NA, and L
% used in the model to compute change in voltage
% K channel only on when voltage is greater
% logical operator implements gating, returns 1 if gate is open, 0 if
% closed. Leakage has no gating as it is always open
I_K  = @(V, n) g_K  * n^4 *(V-V_K);
I_Na = @(V, m, h) g_Na  * m^3 * h * (V-V_Na);
I_L  = @(V) g_L * (V-V_L);
% pump constant, counteracts initial value of I_L
I_P = g_L * (V_init-V_L);

% calculating rate of change of voltage based on currents
dVdt = @(V, n, m, h, I, Na_O, K_O) (I - K_O*I_K(V,n) - Na_O*I_Na(V,m,h) - ...
    I_L(V) + I_P) / C_M;

% when to start and end the current
curr_start = .5;
curr_length = .5;
curr_end = curr_start + curr_length;

% simulation loop
for i=1:num_iterations
    % update time
    t(i+1)= i * dt;
    
    % compute RK4 estimations
    % del 1 estimates
    dV1 = dVdt(V(i)      , n(i)      , m(i)      , h(i)      , I, Na_O, K_O)*dt;
    dN1 = dNdt(V(i)      , n(i)      , m(i)      , h(i)      )*dt;
    dM1 = dMdt(V(i)      , n(i)      , m(i)      , h(i)      )*dt;
    dH1 = dHdt(V(i)      , n(i)      , m(i)      , h(i)      )*dt;
    
    % del 2 estimates
    dV2 = dVdt(V(i)+dV1/2, n(i)+dN1/2, m(i)+dM1/2, h(i)+dH1/2, I, Na_O, K_O)*dt;
    dN2 = dNdt(V(i)+dV1/2, n(i)+dN1/2, m(i)+dM1/2, h(i)+dH1/2)*dt;
    dM2 = dMdt(V(i)+dV1/2, n(i)+dN1/2, m(i)+dM1/2, h(i)+dH1/2)*dt;
    dH2 = dHdt(V(i)+dV1/2, n(i)+dN1/2, m(i)+dM1/2, h(i)+dH1/2)*dt;
    
    %del 3 estimates
    dV3 = dVdt(V(i)+dV2/2, n(i)+dN2/2, m(i)+dM2/2, h(i)+dH2/2, I, Na_O, K_O)*dt;
    dN3 = dNdt(V(i)+dV2/2, n(i)+dN2/2, m(i)+dM2/2, h(i)+dH2/2)*dt;
    dM3 = dMdt(V(i)+dV2/2, n(i)+dN2/2, m(i)+dM2/2, h(i)+dH2/2)*dt;
    dH3 = dHdt(V(i)+dV2/2, n(i)+dN2/2, m(i)+dM2/2, h(i)+dH2/2)*dt;
    
    % del 4 estimates
    dV4 = dVdt(V(i)+dV3  , n(i)+dN3  , m(i)+dM3  , h(i)+dH3  , I, Na_O, K_O)*dt;
    dN4 = dNdt(V(i)+dV3  , n(i)+dN3  , m(i)+dM3  , h(i)+dH3  )*dt;
    dM4 = dMdt(V(i)+dV3  , n(i)+dN3  , m(i)+dM3  , h(i)+dH3  )*dt;
    dH4 = dHdt(V(i)+dV3  , n(i)+dN3  , m(i)+dM3  , h(i)+dH3  )*dt;
    
    % compute value at next time step
    V(i+1) = V(i) + (dV1 + 2*dV2 + 2*dV3 + dV4)/6;
    n(i+1) = n(i) + (dN1 + 2*dN2 + 2*dN3 + dN4)/6;
    m(i+1) = m(i) + (dM1 + 2*dM2 + 2*dM3 + dM4)/6;
    h(i+1) = h(i) + (dH1 + 2*dH2 + 2*dH3 + dH4)/6;
    
    % start/end current pulse
    I = (i*dt > curr_start & i*dt < curr_end) * I_max;
    
    % check to see if Na and K gates are open/closed
    % Voltage is above base threshold and below max, Ka channel not open
    Na_O = (V(i+1) > Na_open & V(i+1) < Na_close) & ~(K_O);
    % Voltage is above threshold or voltage is decreasing
    K_O = ((V(i+1) > K_open) | (V(i+1)-V(i) < 0));
       
end

figure;
hold on;
title("Change in Gating Variable vs Time");
xlabel("Time (ms)");
ylabel("Gating Variable");
plot(t,n);
plot(t,m);
plot(t,h);
legend('n', 'm', 'h');

figure;
hold on;
title("Change in Action Potential vs Time");
xlabel("Time (ms)");
ylabel("Membrane Potential (mV)");
plot(t,V);