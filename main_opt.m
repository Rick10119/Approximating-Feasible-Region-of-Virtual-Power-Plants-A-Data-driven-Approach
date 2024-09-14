%% Test Main Program Using Optimization Data (Joint Optimization of Bidding and Power Allocation)
clc; clear;

% Load data: historical prices and bidding data for past time intervals
load("data_set/data_set_price_bid_opt.mat");
data_set.NOFTRAIN = 20;

% Solution settings
TimeLimit = 120;
param_td = {};

% Split models based on the number of EVs in the agent model
for NOFMODELS = [2]
    
    % Inverse optimization to find optimal parameters based on aggregated model using bidding data before EV aggregation
    
    % Variable naming and initialization
    add_varDef_and_initVal;
    
    max_itr = data_set.NOFTRAIN * 5;
    
    for idx_itr = 0 : max_itr % 10 * NOFDAYS
        % Solve the inverse problem for the idx_day
        idx_day = mod(idx_itr, data_set.NOFTRAIN) + 1;
        
        % Read price and bidding information for the day (MW)
        param.price_e = 1e3 * data_set.Price_e_train(:, idx_day);
        param.price_r = 1e3 * data_set.Price_r_train(:, idx_day);
        bid_e_true = 1e-3 * data_set.Bid_e_train(:, idx_day);
        bid_r_true = 1e-3 * data_set.Bid_r_train(:, idx_day);
        
        % Solve the inverse problem
        inverse_problem;
        
        % Convergence criterion: change in the objective function within the last NOFDAYS cycles
        err = 1e-3;
        if idx_itr > data_set.NOFTRAIN && mean(abs(result_J_theta_conv(end - data_set.NOFTRAIN + 1 : end))) < err
            break;
        end
    end
    
    % Store the fitted parameters
    param_td.P_max_td = value(P_max_td);
    param_td.E_min_td = value(E_min_td);
    param_td.E_max_td = value(E_max_td);
    param_td.E_0_td = value(E_0_td);
    
    save("results/data_td_opt_" + NOFMODELS + "EVs_" + TimeLimit + ".mat", "param_td");
    
    yalmip('clear');
    
end
