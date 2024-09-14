%% Calculate bidding error using identified parameters model
load("..\data_set\data_set_price_bid.mat");
%% Generate Bidding Results Using the Fitted Model

Profit_wrt_day = [];

data_td.Bid_e = [];
data_td.Bid_r = [];
data_td.Profit = [];

% Initialize, estimated values are algebraic sum (MW)
P_max_td = 1e-3 * repmat(ones(1, param.NOFEV) * param.u * param.P_max, NOFEV, 1) / NOFEV;

temp = [(1 - param.u) * param.E_leave, repmat(param.E_leave, param.NOFEV, 1)];
E_min_td = 1e-3 * repmat(ones(1, param.NOFEV) * temp, NOFEV, 1) / NOFEV;
E_min_td(:, 1:12) = 0;

E_max_td = 1e-3 * repmat(param.NOFEV * ([repmat(param.E_max, 1, NOFINTERVALS + 1)]), NOFEV, 1) / NOFEV;
E_0_td = 1e-3 * repmat(param.NOFEV * param.E_0, NOFEV, 1) / NOFEV;

% Normally starts from 15, ends at 28
for day_dx = data_set.NOFTRAIN + 1: 30

    param.price_e = data_set.Price_e(:, day_dx);
    param.price_r = data_set.Price_r(:, day_dx);
    
    % Proposed mechanism
    cd ..\
    bid_primal_problem;
    cd visualization
    
    data_td.Bid_e = [data_td.Bid_e, Bid_P_init];
    data_td.Bid_r = [data_td.Bid_r, Bid_R_init];
    data_td.Profit = [data_td.Profit, Profit_init];

    yalmip('clear');
end

% Compare errors

% Bidding error: RMSE
mean(mean(abs([data_set.Bid_e_test - 1e3 * data_td.Bid_e, ...
    data_set.Bid_r_test - 1e3 * data_td.Bid_r]))) ...
   / max(max(abs([data_set.Bid_e_test, data_set.Bid_r_test])))
