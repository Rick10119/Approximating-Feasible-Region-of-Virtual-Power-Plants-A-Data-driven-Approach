%% Bidding Strategy, Starting from Time Slot 1

% Existing literature approach, i.e., proportionally allocating frequency regulation signals

% Input: Energy and frequency regulation market prices for each time slot; 
% Electric vehicle arrival and departure time slots, energy;
% Output: Bidding quantity for each time slot, battery energy

%% Parameter Settings

delta_t = 1;

%% Variables
% Bidding capacity: energy, frequency (kW)
Bid_P = sdpvar(NOFINTERVALS, NOFEV, 'full'); 
Bid_R = sdpvar(NOFINTERVALS, NOFEV, 'full'); 

% Auxiliary variables
P_dis = sdpvar(NOFEV, NOFINTERVALS, 'full'); % EV discharge power in each scenario (kW)
P_ch = sdpvar(NOFEV, NOFINTERVALS, 'full'); % EV charge power in each scenario (kW)
E = sdpvar(NOFEV, NOFINTERVALS + 1, 'full'); % EV battery energy at the beginning of each time slot (kWh), including the departure time slot
Cost_deg = sdpvar(NOFEV, NOFINTERVALS, 'full'); % Aging cost for each time slot and scenario ($)

%% Objective Function
% Energy revenue, frequency capacity revenue, frequency mileage revenue, deployment cost, performance cost
Profit = sum(param.price_e' * Bid_P + param.price_r' * Bid_R) - ...
     sum(sum(Cost_deg));
 
% Multiply by time slot length
Profit = Profit * delta_t;

%% Constraints

Constraints = [];

% Initial energy level at arrival (4th column) for each EV, dual variable for this constraint is lambda
Constraints = [Constraints, E(:, 1) == param.E_0];

% Non-negativity constraint for frequency regulation capacity (NOFINTERVALS)
Constraints = [Constraints, 0 <= Bid_R];
    
% Power limits (kW) (NOFEV * NOFINTERVALS)
Constraints = [Constraints, 0 <= P_dis];
Constraints = [Constraints, 0 <= P_ch];
Constraints = [Constraints, Bid_R' <= param.u * param.P_max - Bid_P'];
Constraints = [Constraints, Bid_R' <= param.u * param.P_max + Bid_P'];
Constraints = [Constraints, P_dis - P_ch == Bid_P'];

% Discharge aging ($) (NOFINTERVALS)
Constraints = [Constraints, Cost_deg == param.Pr_deg * P_dis];

% Energy correlation between time slots (kWh)
% At departure, energy level should be at least 90% (5th column) for each EV
Constraints = [Constraints, E(:, end) >= param.E_leave];

% Energy levels in intermediate time slots should be between min and max (NOFEV * NOFINTERVALS)
Constraints = [Constraints, repmat(param.E_min, NOFEV, NOFINTERVALS + 1) <= E];
Constraints = [Constraints, E <= repmat(param.E_max, NOFEV, NOFINTERVALS + 1)];

% Continuous output constraint for frequency bidding (NOFINTERVALS)
Constraints = [Constraints, repmat(param.eta, NOFEV, NOFINTERVALS) .* (E(:, 1 : end-1) - repmat(param.E_min, NOFEV, NOFINTERVALS)) ...
    >= Bid_R' * 0.25 * delta_t + Bid_P' * delta_t];
Constraints = [Constraints, repmat(1 ./ param.eta, NOFEV, NOFINTERVALS) .* (- E(:, 1 : end-1) + repmat(param.E_max, NOFEV, NOFINTERVALS)) ...
    >= Bid_R' * 0.25 * delta_t - Bid_P' * delta_t];

% Connection between consecutive time slots (NOFEV * NOFINTERVALS)
Constraints = [Constraints, E(:, 2 : end) == E(:, 1 : end - 1) + (param.eta * P_ch ...
    - 1/param.eta * P_dis) * delta_t];

%% Solve
ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);

sol = optimize(Constraints, - Profit, ops);

if sol.problem == 0 % Successful optimization
    disp("Time Slot 1: Bidding successful.")
else 
    disp("Time Slot 1: Bidding failed.")
end

%% Recording
Bid_R_init = sum(value(Bid_R'))';
Bid_P_init = sum(value(Bid_P'))';
Profit_init = value(Profit);
E_init = value(E);
