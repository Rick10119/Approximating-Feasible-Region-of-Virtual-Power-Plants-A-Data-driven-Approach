% Data Preparation

%% Bidding Strategy, Starting from Time Slot 1

% Used for: 1. Initial value generation; 2. Calculation of Lagrange multipliers

% Input: Energy and frequency regulation market prices for each time slot; 
% Electric vehicle arrival and departure time slots, energy;
% Output: Bidding quantity for each time slot, battery energy

%% Parameter Settings

NOFSCEN = 22;
param.hourly_Distribution = repmat(1/NOFSCEN * ones(1, NOFSCEN), NOFINTERVALS, 1);

param.d_s = [-1; [-0.95 : 0.1 : 0.95]'; 1];

%% Variables
% Bidding capacity: energy, frequency regulation (MW)
Bid_P = sdpvar(NOFINTERVALS, 1, 'full'); 
Bid_R = sdpvar(NOFINTERVALS, 1, 'full'); 

% Auxiliary variables
P_dis = sdpvar(NOFEV, NOFINTERVALS, NOFSCEN, 'full'); % EV discharge power in each scenario (kW)
P_ch = sdpvar(NOFEV, NOFINTERVALS, NOFSCEN, 'full'); % EV charge power in each scenario (kW)
E = sdpvar(NOFEV, NOFINTERVALS + 1, 'full'); % EV battery energy at the beginning of each time slot (kWh), including the departure time slot
Cost_deg = sdpvar(NOFINTERVALS, NOFSCEN, 'full'); % Aging cost for each time slot and scenario ($)

%% Objective Function
% Energy revenue, frequency capacity revenue, frequency mileage revenue, deployment cost, performance cost
Profit = sum(param.price_e' * Bid_P + param.price_r' * Bid_R) - ...
     sum(sum(param.hourly_Distribution .* Cost_deg));
% Multiply by time slot length
Profit = Profit * delta_t;

%% Constraints

Constraints = [];

% Initial energy level at arrival (4th column) for each EV, dual variable for this constraint is lambda
Constraints = [Constraints, E(:, 1) == param.E_0];

% Non-negativity constraint for frequency regulation capacity (NOFINTERVALS)
Constraints = [Constraints, 0 <= Bid_R];

% Power response - Balance in each scenario (NOFINTERVALS * NOFSCEN)
temp = permute(sum(P_dis - P_ch), [2, 3, 1]); % Aggregate EV power
temp = reshape(temp, NOFINTERVALS, NOFSCEN);

Constraints = [Constraints, repmat(Bid_P, 1, NOFSCEN) + ...
    repmat(Bid_R, 1, NOFSCEN) .* repmat(param.d_s', NOFINTERVALS, 1) - temp == 0];
    
% Power limits (kW) (NOFEV * NOFINTERVALS * NOFSCEN)
Constraints = [Constraints, 0 <= P_dis];
Constraints = [Constraints, 0 <= P_ch];
Constraints = [Constraints, P_dis <= repmat(param.u, 1, 1, 22) * param.P_max];
Constraints = [Constraints, P_ch <= repmat(param.u, 1, 1, 22) * param.P_max];

% Discharge aging ($) (NOFINTERVALS * NOFSCEN)
temp = permute(sum(repmat(param.Pr_deg, NOFEV, NOFINTERVALS, NOFSCEN) .* P_dis), [2, 3, 1]); % Aggregate EV power, swap rows and columns
temp = reshape(temp, NOFINTERVALS, NOFSCEN);

Constraints = [Constraints, Cost_deg == temp];

% Energy correlation between time slots (kWh)
% At departure, energy level should be at least 90% (5th column) for each EV
Constraints = [Constraints, E(:, end) >= param.E_leave];

% Energy levels in intermediate time slots should be between min and max (NOFEV * NOFINTERVALS)
Constraints = [Constraints, repmat(param.E_min, NOFEV, NOFINTERVALS + 1) <= E];
Constraints = [Constraints, E <= repmat(param.E_max, NOFEV, NOFINTERVALS + 1)];

% Continuous output constraint for frequency bidding (NOFINTERVALS)
Constraints = [Constraints, sum(param.eta' * (E(:, 1 : end-1) - repmat(param.E_min, NOFEV, NOFINTERVALS))) >= Bid_R' * 0.25 * delta_t + Bid_P' * delta_t];
Constraints = [Constraints, sum((1 ./ param.eta)' * (- E(:, 1 : end-1) + repmat(param.E_max, NOFEV, NOFINTERVALS))) >= Bid_R' * 0.25 * delta_t - Bid_P' * delta_t];

% Connection between consecutive time slots (NOFEV * NOFINTERVALS)
temp = P_ch .* repmat(param.eta, NOFEV, NOFINTERVALS, NOFSCEN) - ...
    P_dis .* repmat(1 ./ param.eta, NOFEV, NOFINTERVALS, NOFSCEN);
temp = permute(temp, [3, 2, 1]); % Swap rows and columns
temp = reshape(temp, NOFSCEN, NOFINTERVALS * NOFEV); % Flatten power for SCEN * (SLOTS * EV)
temp2 = repmat(param.hourly_Distribution', 1, NOFEV); % Repeat distribution for SCEN * (SLOTS * EV)
temp = sum(temp .* temp2); % Multiply and weight by probability
temp = reshape(temp, NOFINTERVALS, NOFEV)'; % Rewrite as SLOTS * EV and transpose to EV * SLOTS

Constraints = [Constraints, E(:, 2 : end) == E(:, 1 : end - 1) + temp * delta_t];

%% Solve
ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);

sol = optimize(Constraints, - Profit, ops);

if sol.problem == 0 % Successful optimization
    disp("Time Slot 1: Bidding successful.")
else 
    disp("Time Slot 1: Bidding failed.")
end

%% Recording
Bid_R_init = value(Bid_R);
Bid_P_init = value(Bid_P);
