%% Prepare parameter settings
param = {};

param.delta_t = 1;
param.delta_t_req = 0.25;

%% Read EV arrival data
%%
% Read EV arrival time from Excel
filename = 'EV_arrive_leave.xlsx';
sheet = 'EV_arrive_leave'; % Sheet name
xlRange = 'A2:C4013'; % Range

EV_arrive_leave = xlsread(filename, sheet, xlRange);

NOFEV = size(EV_arrive_leave, 1);

% EV number, arrival time slot, departure time slot
% Adjust arrival and departure time (second column)
col = 2;
for i = 1 : NOFEV
    if EV_arrive_leave(i, col) ~= 1
        EV_arrive_leave(i, col) = ceil(EV_arrive_leave(i, col) / 4) + 2; % Arrival time: round up
    end
    if EV_arrive_leave(i, col + 1) < 57
        EV_arrive_leave(i, col + 1) = floor((EV_arrive_leave(i, col + 1)) / 4) + 1; % Departure time: round down
    end
    if EV_arrive_leave(i, col + 1) == 57
        EV_arrive_leave(i, col + 1) = 16;
    end
end

param.NOFEV = NOFEV;
param.EV_arrive_leave = EV_arrive_leave;

clear EV_arrive_leave;

%% Read RegD signal data

% Number of time slots, 24 hours. We only consider 16 hours.
NOFSLOTS = 16;

day_reg = day_dx;
day_price = day_dx;

hour_init = 18; % Starting from 18:00-19:00 (originally the 19th time slot)

%% EV parameters
% Frequency regulation performance
param.s_perf = 0.984;
% Maximum power (kW), capacity upper and lower limits (kWh)
param.P_max = 7.68;

% Charge and discharge efficiency
param.eta = 0.95;
param.Pr_deg = 0.1;
param.E_max = 50;

param.Pr_deg = param.Pr_deg';
param.eta = param.eta';
param.E_max = param.E_max';
param.E_0 = 0;
param.E_min = 0;
param.E_leave = 40;

% Charging status u
u = zeros(NOFEV, NOFSLOTS);
for idx = 1 : NOFEV
    for jdx = 1 : NOFSLOTS
        if param.EV_arrive_leave(idx, 2) <= jdx && jdx <= param.EV_arrive_leave(idx, 3)
            u(idx, jdx) = 1;
        end
    end
end
param.u = u;
clear u;

%% Market prices and other parameters
% Time slot length, 1 hour
delta_t = 1;
