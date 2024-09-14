%% Optimal Bidding for Forward Linear Programming Problem for Hourly Bidding

% Set Parameters
% (P_max, e_max)

%% Example Parameters

% Number of time intervals
NOFINTERVALS = 16;
% Number of electric vehicles, initially set to 1
NOFEV = size(param_td.P_max_td, 1);

% Time interval length
delta_t = 1;

%% Variable Setup
% Bidding capacity: energy, frequency (kW)
Bid_P = sdpvar(NOFINTERVALS, NOFEV, 'full'); 
Bid_R = sdpvar(NOFINTERVALS, NOFEV, 'full'); 

% Auxiliary variables
P_dis = sdpvar(NOFEV, NOFINTERVALS, 'full'); % EV discharging power in different scenarios (kW)
P_ch = sdpvar(NOFEV, NOFINTERVALS, 'full'); % EV charging power in different scenarios (kW)
E = sdpvar(NOFEV, NOFINTERVALS + 1, 'full'); % EV battery energy at the beginning of each interval (kWh), including departure time (beginning of interval), hence one additional dimension
Cost_deg = sdpvar(NOFEV, NOFINTERVALS, 'full'); % Aging costs in each interval for each scenario ($)

% Problem parameters
% P_max_td = P_max_td_ref;
% E_min_td = E_min_td_ref;
% E_max_td = E_max_td_ref;
% E_0_td = E_0_td_ref; % Aggregated energy initial value
% param.price_e = data_set.Price_e(:, 3);
% param.price_r = data_set.Price_r(:, 3);

% Variables and constraints
add_primal_constraints;

%% Solve
ops = sdpsettings('debug',1,'solver','gurobi','savesolveroutput',1,'savesolverinput',1);

sol = optimize(Constraints_primal, Z_primal, ops);

%% Record the optimal bidding results and corresponding profit
Bid_R_init = value(Bid_R * ones(NOFEV, 1));
Bid_P_init = value(Bid_P * ones(NOFEV, 1));
Profit_init = value(Profit);
