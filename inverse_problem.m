%% Estimating Aggregate Model Parameters Based on Meter Data

%% Constraints
Constraints = [];

% Dual problem variables and constraints
add_dual_constraints;
% Add dual constraints
Constraints = [Constraints, Constraints_dual];

% Original problem variables and constraints
add_primal_constraints;
% Add original problem constraints
Constraints = [Constraints, Constraints_primal];

% Equality of objective function values (only need equality between dual and primal function values, not with real data)
Constraints = [Constraints, g_dual == Z_primal];

%% Inverse Problem Objective Function

% Loss function: Fitting degree of historical bidding data
J_theta = norm(Bid_P * ones(NOFEV, 1) - bid_e_true)^2 ...
    + norm(Bid_R * ones(NOFEV, 1) - bid_r_true)^2;

% Add terms to prevent non-convergence

J_theta_conv = sum(sum((P_max_td - P_max_td_ref).^2)) ...
    + sum(sum((E_min_td - E_min_td_ref).^2)) + sum(sum((E_max_td - E_max_td_ref).^2)) ...
    + sum(sum((E_0_td - E_0_td_ref).^2));

% Gradually decrease learning rate (adaptive)
if (idx_itr > 3 * data_set.NOFTRAIN) && isAdapt == 0
    isAdapt = 1;
    idx_itr_Adapt = idx_itr;
end

% If adaptation has started, reduce the weight of J_theta
if isAdapt
    alpha = (1 / (idx_itr - idx_itr_Adapt + 1))^(0.5);
else
    alpha = 1;
end

beta = 0.01;
J_theta_total = J_theta * alpha + J_theta_conv * beta;

%% Solve

ops = sdpsettings('debug',1,'solver','gurobi', ...
    'verbose', 0, ...
    'gurobi.NonConvex', 2, ...
    'allownonconvex',1, ...
    'gurobi.TimeLimit', TimeLimit, 'usex0', 1);
ops.gurobi.TuneTimeLimit = TimeLimit;
sol = optimize(Constraints, J_theta_total, ops);

%% Update Parameters

% Record loss function
result_J_theta = [result_J_theta; value(J_theta)];
result_J_theta_conv = [result_J_theta_conv; value(J_theta_conv)];

% Record iteration process
result_P_max_td = [result_P_max_td; value(P_max_td)];
result_E_min_td = [result_E_min_td; value(E_min_td)];
result_E_max_td = [result_E_max_td; value(E_max_td)];

if idx_itr >= data_set.NOFTRAIN - 1
    % Update parameters based on the mean of the past training cycle
    temp1 = NOFMODELS * data_set.NOFTRAIN;
    temp = result_P_max_td(end - temp1 + 1 : end, :);
    for idx = 1 : NOFMODELS
        P_max_td_ref(idx, :) = mean(temp(idx : NOFMODELS : end, :));
    end

    temp = result_E_max_td(end - temp1 + 1 : end, :);
    for idx = 1 : NOFMODELS
        E_max_td_ref(idx, :) = mean(temp(idx : NOFMODELS : end, :));
    end

    temp = result_E_min_td(end - temp1 + 1 : end, :);
    for idx = 1 : NOFMODELS
        E_min_td_ref(idx, :) = mean(temp(idx : NOFMODELS : end, :));
    end
end

% Use these as initial values
assign(P_max_td, P_max_td_ref);
assign(E_min_td, E_min_td_ref);
assign(E_max_td, E_max_td_ref);

%% Display Training Process
disp("Iteration Count: " + idx_itr)
disp("Training Loss Function J_theta / J_theta_conv: " + value(J_theta) + " / " + value(J_theta_conv))

if idx_itr > data_set.NOFTRAIN
    disp("Training Loss Function J_theta(idx - NOFTRAIN): " + result_J_theta(end - data_set.NOFTRAIN))
end
