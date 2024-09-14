%% Define Relevant Variables and Initialize

% Number of intervals
NOFINTERVALS = 16;
% Length of each interval
delta_t = 1;
% Adaptive start flag
isAdapt = 0;
idx_itr_Adapt = 0;
NOFEV = NOFMODELS;

%% Variable Settings

% Agent model parameters
P_max_td = sdpvar(NOFEV, NOFINTERVALS, 'full'); % Aggregate power upper limit
E_min_td = sdpvar(NOFEV, NOFINTERVALS + 1, 'full'); % Aggregate energy lower limit
E_max_td = sdpvar(NOFEV, NOFINTERVALS + 1, 'full'); % Aggregate energy upper limit
E_0_td = zeros(NOFEV, 1); % Initial aggregate energy

% Bidding capacity: energy, frequency regulation (kW)
Bid_P = sdpvar(NOFINTERVALS, NOFEV, 'full'); 
Bid_R = sdpvar(NOFINTERVALS, NOFEV, 'full'); 

% Auxiliary variables
P_dis = sdpvar(NOFEV, NOFINTERVALS, 'full'); % EV discharging power in each scenario (kW)
P_ch = sdpvar(NOFEV, NOFINTERVALS, 'full'); % EV charging power in each scenario (kW)
E = sdpvar(NOFEV, NOFINTERVALS + 1, 'full'); % EV battery energy at the beginning of each time interval (kWh), including departure time (beginning of interval), hence an extra dimension
Cost_deg = sdpvar(NOFEV, NOFINTERVALS, 'full'); % Aging cost for each scenario in each time interval ($)

% Dual variables
mu_pd_min = sdpvar(NOFEV, NOFINTERVALS, 'full');
mu_pc_min = sdpvar(NOFEV, NOFINTERVALS, 'full');
mu_e_min = sdpvar(NOFEV, NOFINTERVALS + 1, 'full');
mu_e_max = sdpvar(NOFEV, NOFINTERVALS + 1, 'full');
mu_r_min = sdpvar(NOFEV, NOFINTERVALS, 'full');
mu_rpd = sdpvar(NOFEV, NOFINTERVALS, 'full');
mu_rpc = sdpvar(NOFEV, NOFINTERVALS, 'full');
mu_red = sdpvar(NOFEV, NOFINTERVALS, 'full');
mu_rec = sdpvar(NOFEV, NOFINTERVALS, 'full');
lambda_e = sdpvar(NOFEV, NOFINTERVALS, 'full');
lambda_e0 = sdpvar(NOFEV, 1, 'full');

%% Iterative Parameter Solving

% Initialization
result_P_max_td = [];
result_E_min_td = [];
result_E_max_td = [];
result_E_0_td = [];
result_J_theta = [];
result_J_theta_conv = [];

% Initialization, estimated values are algebraic sum (MW)
P_max_td_ref = 1e-3 * repmat(ones(1, param.NOFEV) * param.u * param.P_max, NOFEV, 1) / NOFEV;

temp = [(1 - param.u) * param.E_leave, repmat(param.E_leave, param.NOFEV, 1)];
E_min_td_ref = 1e-3 * repmat(ones(1, param.NOFEV) * temp, NOFEV, 1) / NOFEV;
E_min_td_ref(:, 1 : 12) = 0;

E_max_td_ref = 1e-3 * repmat(param.NOFEV * ([repmat(param.E_max, 1, NOFINTERVALS + 1)]), NOFEV, 1) / NOFEV;
E_0_td_ref = 1e-3 * repmat(param.NOFEV * param.E_0, NOFEV, 1) / NOFEV;

% Record initial values
result_P_max_td = [result_P_max_td; P_max_td_ref];
result_E_min_td = [result_E_min_td; E_min_td_ref];
result_E_max_td = [result_E_max_td; E_max_td_ref];
result_E_0_td = [result_E_0_td; E_0_td_ref];

% Set variable initial values
assign(P_max_td, P_max_td_ref);
assign(E_min_td, E_min_td_ref);
assign(E_max_td, E_max_td_ref);
