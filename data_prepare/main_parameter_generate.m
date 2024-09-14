%% Main function for generating parameters

data_set = {};

data_set.Price_e = [];

data_set.Price_r = [];
% Generate prices
for day_dx = 1 : 30
    
    day_price = day_dx; % Price: May 20th
    
    generate_market_parameter;
    
    data_set.Price_e = [data_set.Price_e, param.price_e];
    data_set.Price_r = [data_set.Price_r, param.price_r];

end

generate_ev_parameter;

save("..\data_set\data_set_price.mat", 'data_set', 'param');
