%% Calculate Bidding Errors Using Identified Parameters

% load("..\data_set\data_set_price_bid.mat");
% load("..\results\data_td_2EVs_120.mat");

%% Generate Bidding Results Using the Fitted Model

data_td.Bid_e = [];
data_td.Bid_r = [];
data_td.Profit = [];

P_max_td = param_td.P_max_td;
E_min_td = param_td.E_min_td;
E_max_td = param_td.E_max_td;
E_0_td = param_td.E_0_td;

% Normally starts from 15 and ends at 28
for day_dx = data_set.NOFTRAIN + 1 : 30
    % data_set.NOFTRAIN + 
    param.price_e = data_set.Price_e(:, day_dx);
    param.price_r = data_set.Price_r(:, day_dx);
    
    % Bidding mechanism
    cd ..\ % Change directory to go up one level
    bid_primal_problem;
    cd visualization % Change directory back to the visualization folder
    
    data_td.Bid_e = [data_td.Bid_e, Bid_P_init];
    data_td.Bid_r =  [data_td.Bid_r, Bid_R_init];
    data_td.Profit = [data_td.Profit, Profit_init];
    
    yalmip('clear');
end


% Compare Errors

% Bidding Error: RMSE
mean(mean(abs([data_set.Bid_e_test - 1e3 * data_td.Bid_e, ...
    data_set.Bid_r_test - 1e3 * data_td.Bid_r]))) ...
    / max(max(abs([data_set.Bid_e_test, data_set.Bid_r_test])))
