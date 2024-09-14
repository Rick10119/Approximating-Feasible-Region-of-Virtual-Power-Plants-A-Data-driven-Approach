%% Generate results on different days (opt: considering bidding and power allocation models)
M = 1e3; % Large number
NOFDAYS = 30;
NOFINTERVALS = 16;
Profit_wrt_day = [];

load("..\..\data_set\data_set_price.mat");
NOFEV = size(param.EV_arrive_leave, 1);

data_set.Bid_e = [];
data_set.Bid_r = [];
data_set.Profit = [];

sol_time = [];
% Normally starts from 15 and ends at 28
for day_dx = 1 : NOFDAYS

    param.price_e = data_set.Price_e(:, day_dx);
    param.price_r = data_set.Price_r(:, day_dx);
    
    % Bidding mechanism
    tic;
    maxProfit_1_opt;
    sol_time = [sol_time; toc];
    data_set.Bid_e = [data_set.Bid_e, Bid_P_init];
    data_set.Bid_r =  [data_set.Bid_r, Bid_R_init];
    data_set.Profit = [data_set.Profit, Profit_init];

    yalmip('clear');
end

%% Divide the dataset
NOFTRAIN = 2/3 * NOFDAYS;
NOFTEST = 1/3 * NOFDAYS;

data_set.Price_e_train = data_set.Price_e(:, 1 : NOFTRAIN);
data_set.Price_e_test = data_set.Price_e(:, NOFTRAIN + 1 : end);
data_set.Price_r_train = data_set.Price_r(:, 1 : NOFTRAIN);
data_set.Price_r_test = data_set.Price_r(:, NOFTRAIN + 1 : end);

data_set.Bid_e_train = data_set.Bid_e(:, 1 : NOFTRAIN);
data_set.Bid_e_test = data_set.Bid_e(:, NOFTRAIN + 1 : end);
data_set.Bid_r_train = data_set.Bid_r(:, 1 : NOFTRAIN);
data_set.Bid_r_test = data_set.Bid_r(:, NOFTRAIN + 1 : end);

data_set.NOFTRAIN = NOFTRAIN;
data_set.NOFTEST = NOFTEST;
save("..\data_set\data_set_price_bid_opt.mat", "data_set", "param");
