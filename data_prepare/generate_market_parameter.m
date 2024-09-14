%% Prepare parameter settings
param = {};

%% Read RegD signal data

% Number of time slots, 24 hours. We only consider 16 hours.
NOFSLOTS = 16;

day_reg = day_dx;
day_price = day_dx;

hour_init = 18; % Starting from 18:00-19:00 (originally the 19th time slot)

%% Read signal data from Excel
filename = '07 2020.xlsx';
sheet = 'Dynamic'; % Sheet name
xlRange = 'B2:AF43202'; % Range

% Read all signal data for July, 2 seconds per data point * 31 days
Signals = xlsread(filename, sheet, xlRange);

% Data cleaning, exclude data points outside the range [-1, 1]
Signals(Signals < -1) = -1;
Signals(Signals > 1) = 1;

% Process RegD data
%% Process the original signal data
%% Organize with 0.1 resolution: 1) RegD signal distribution for this month, 2) RegD signal distribution for July 15th

% Starting from 6:00 PM on the first day to 6:00 PM on the second day
Signals = [Signals(hour_init * 1800 + 1:end, 1:end - 1); Signals(1:hour_init * 1800, 2:end)];

nofHisDays = 1;
signal_length = 43202 - 2; % Excluding the first and last data points, total of 24*1800

% Use data from the early hours of the 17th and 18th for simulation
Signal_day = Signals(:, day_reg);

% Distribution for each hour
hourly_Distribution = [];
hourly_Mileage = [];

for hour = 1:24
    
    Distributions = [];
    
    %% Calculate mileage
    
    Mileage = [];
    day_idx = day_reg; % Use data from the past two weeks
        
    % Extract column (one day)
    signals = Signals(1 + (hour - 1) * 1800:hour * 1800, day_idx);
        
    % Calculate mileage for this hour
    mileage = sum(abs(signals(2:end) - signals(1:end - 1)));
    Mileage = [Mileage, mileage];
    
    Mileage = Mileage * 1 / nofHisDays * ones(nofHisDays, 1);
    
    hourly_Mileage = [hourly_Mileage, Mileage];
    
end

%% Rows: different intervals; Columns (different times)
param.hourly_Mileage = hourly_Mileage';

% Consider only 16 hours
param.hourly_Mileage = param.hourly_Mileage(1:NOFSLOTS, :);

clear Mileage mileage signals Distributions Distribution hourly_Distribution hourly_Mileage nofHisDays
clear col s_idx Signals
clear filename hour sheet t_cap xlRange day_idx

%% EV parameters
% Frequency regulation performance
param.s_perf = 0.984;

%% Market prices and other parameters
% Time slot length, 1 hour
delta_t = 1;

% Read regulation market price data
filename = 'regulation_market_results.xlsx';
sheet = 'regulation_market_results'; % Sheet name
start_row = (day_price - 1) * 24 + hour_init + 2; % Starting row
xlRange = "G" + start_row + ":H" + (start_row + NOFSLOTS - 1); % Range
param.price_reg = xlsread(filename, sheet, xlRange); % Capacity price, mileage price

% Read system energy price data
filename = 'rt_hrl_lmps.xlsx';
sheet = 'rt_hrl_lmps'; % Sheet name
xlRange = "I" + start_row + ":I" + (start_row + NOFSLOTS - 1); % Range
param.price_e = xlsread(filename, sheet, xlRange); % Capacity price, mileage price

% Organize composite prices
param.price_r = param.s_perf * (param.price_reg(:, 1) + param.hourly_Mileage .* param.price_reg(:, 2));

% Adjust to kWh
param.price_r = 1e-3 * param.price_r;
param.price_e = 1e-3 * param.price_e;

clear price filename sheet xlRange start_row signal_length i idx jdx
