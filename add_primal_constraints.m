%% Incorporate Constraints of the Original Problem
% Compared to the data generation problem, some parameters have now become variables, and the scale has reduced

%% Constraints
Constraints_primal = [];

% Frequency capacity non-negativity. NOFINTERVALS
Constraints_primal = [Constraints_primal, 0 <= Bid_R];

% Initial energy level constraint at time 0 (fourth column). NOFEV, with dual variable lambda
Constraints_primal = [Constraints_primal, E(:, 1) == E_0_td];

% Power limits (kW). NOFEV * NOFINTERVALS
Constraints_primal = [Constraints_primal, 0 <= P_dis];
Constraints_primal = [Constraints_primal, 0 <= P_ch];
Constraints_primal = [Constraints_primal, Bid_R' <= P_max_td - Bid_P'];
Constraints_primal = [Constraints_primal, Bid_R' <= P_max_td + Bid_P'];
Constraints_primal = [Constraints_primal, P_dis - P_ch == Bid_P'];

% Discharge aging ($) NOFINTERVALS
Constraints_primal = [Constraints_primal, Cost_deg == param.Pr_deg * P_dis];

% Energy correlation between intervals (kWh)

% Energy in intermediate intervals within min and max bounds. NOFEV * NOFINTERVALS
Constraints_primal = [Constraints_primal, E_min_td <= E];
Constraints_primal = [Constraints_primal, E <= E_max_td];

% Continuous output constraint for frequency bidding. NOFINTERVALS
Constraints_primal = [Constraints_primal, repmat(param.eta, NOFEV, NOFINTERVALS) .* (E(:, 1 : end-1) - E_min_td(:, 1 : end-1)) ...
    >= Bid_R' * param.delta_t_req + Bid_P' * delta_t];
Constraints_primal = [Constraints_primal, repmat(1 ./ param.eta, NOFEV, NOFINTERVALS) .* (- E(:, 1 : end-1) + E_max_td(:, 1 : end-1)) ...
    >= Bid_R' * param.delta_t_req - Bid_P' * delta_t];

% Connection between consecutive intervals. NOFEV * NOFINTERVALS
Constraints_primal = [Constraints_primal, E(:, 2 : end) == E(:, 1 : end - 1) + (param.eta * P_ch ...
    - 1/param.eta * P_dis) * delta_t];

%% Objective Function
% Energy revenue, frequency capacity revenue, frequency mileage revenue, deployment cost, performance cost
Profit = sum(param.price_e' * Bid_P + param.price_r' * Bid_R) - ...
     sum(sum(Cost_deg));
 
% Multiply by time interval length
Z_primal = - Profit * delta_t;
