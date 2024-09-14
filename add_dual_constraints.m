%% Adding Dual Constraints
Constraints_dual = [];

% Constraints corresponding to P_dis
Constraints_dual = [Constraints_dual, repmat(param.Pr_deg, NOFEV, NOFINTERVALS) ...
    - repmat(param.price_e', NOFEV, 1) - mu_pd_min - delta_t/param.eta * lambda_e ...
    + mu_rpd - mu_rpc + mu_red - mu_rec == 0];

% Constraints corresponding to P_ch
Constraints_dual = [Constraints_dual, repmat(param.price_e', NOFEV, NOFINTERVALS) - mu_pc_min ...
    + delta_t * param.eta * lambda_e ...
    - mu_rpd + mu_rpc - mu_red + mu_rec == 0];

% Constraints for e (t>1)
Constraints_dual = [Constraints_dual, - mu_e_min(:, 1 : end - 1) + mu_e_max(:, 1 : end - 1) ...
    + lambda_e(:, 1 : end) - [lambda_e0, lambda_e(:, 1 : end - 1)] ...
    - mu_red + mu_rec == 0];
% Constraints for e (t = T + 1)
Constraints_dual = [Constraints_dual, - mu_e_min(:, end) + mu_e_max(:, end) ...
    - lambda_e(:, end) == 0];

% Constraints for r
Constraints_dual = [Constraints_dual, - repmat(param.price_r', NOFEV, 1) ...
    - mu_r_min + mu_rpd + mu_rpc ...
    + param.delta_t_req * param.eta * mu_rec + param.delta_t_req / param.eta * mu_red == 0];

% Dual feasibility
Constraints_dual = [Constraints_dual, mu_pd_min >= 0];
Constraints_dual = [Constraints_dual, mu_pc_min >= 0];
Constraints_dual = [Constraints_dual, mu_e_min >= 0];
Constraints_dual = [Constraints_dual, mu_e_max >= 0];
Constraints_dual = [Constraints_dual, mu_r_min >= 0];
Constraints_dual = [Constraints_dual, mu_rpd >= 0];
Constraints_dual = [Constraints_dual, mu_rpc >= 0];
Constraints_dual = [Constraints_dual, mu_red >= 0];
Constraints_dual = [Constraints_dual, mu_rec >= 0];

% Dual Problem Objective Function
g_dual = sum(sum(E_min_td .* mu_e_min)) - sum(sum(E_max_td .* mu_e_max)) ...
    - sum(sum(P_max_td .* mu_rpd)) - sum(sum(P_max_td .* mu_rpc)) ...
    + sum(sum(E_min_td(:, 1 : end - 1) .* mu_red)) ...
    - sum(sum(E_max_td(:, 1 : end - 1) .* mu_rec)) ...
    + sum(E_0_td .* lambda_e0); 

%% Prior Assumptions
M = 1e3;

Constraints_priori = [];
% Limit variable size
% Basic parameter constraints (not necessary to restrict non-negativity with original problem constraints)
Constraints_priori = [Constraints_priori, P_max_td  <= M];
Constraints_priori = [Constraints_priori, E_min_td  >= 0];
Constraints_priori = [Constraints_priori, E_min_td(:, 1 : 12)  == 0];
Constraints_priori = [Constraints_priori, E_max_td  <= M];

% Dual variable constraints
Constraints_priori = [Constraints_priori, mu_pd_min <= M];
Constraints_priori = [Constraints_priori, mu_pc_min <= M];
Constraints_priori = [Constraints_priori, mu_e_min <= M];
Constraints_priori = [Constraints_priori, mu_e_max <= M];
Constraints_priori = [Constraints_priori, mu_r_min <= M];
Constraints_priori = [Constraints_priori, mu_rpd <= M];
Constraints_priori = [Constraints_priori, mu_rpc <= M];
Constraints_priori = [Constraints_priori, mu_red <= M];
Constraints_priori = [Constraints_priori, mu_rec <= M];
Constraints_priori = [Constraints_priori, lambda_e <= M];
Constraints_priori = [Constraints_priori, lambda_e0 <= M];
