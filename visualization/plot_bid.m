%% Plot the bidding results of the aggregated model
load("..\data_set\data_set_price_bid.mat");
load("..\results\data_td_1EVs_120.mat");

calculate_error;

x = sum(abs(data_set.Bid_e_test - 1e3 * data_td.Bid_e) + ...
    abs(data_set.Bid_r_test - 1e3 * data_td.Bid_r));
idx_day_min = find(x == min(x));

%
Bid_R_comp = [1e-3 * data_set.Bid_r_test(:, idx_day_min), data_td.Bid_r(:, idx_day_min)];
Bid_P_comp = [1e-3 * data_set.Bid_e_test(:, idx_day_min), data_td.Bid_e(:, idx_day_min)];

% Direct sum (outer approximation) of bidding results
calculate_error_direct;
Bid_R_comp = [Bid_R_comp, data_td.Bid_r(:, idx_day_min)];
Bid_P_comp = [Bid_P_comp, data_td.Bid_e(:, idx_day_min)];

%% Plot

linewidth = 1;

% Adjusted frequency capacity
plot([Bid_R_comp(:, 1)] ...
    , "-g", 'linewidth', linewidth);hold on;
plot([Bid_R_comp(:, 3)] ...
    , "-b", 'linewidth', linewidth);
plot([Bid_R_comp(:, 2)] ...
    , "-r", 'linewidth', linewidth);
% Actual energy

linewidth = 1.1;
temp = 1:16;
Bid_P_comp = [Bid_P_comp(:, 1), Bid_P_comp(:, 3), Bid_P_comp(:, 2)];
b = bar(Bid_P_comp, linewidth);hold on;
set(b(1), 'facecolor', [[0 1 0]]);
set(b(2), 'facecolor', [[0 0 1]]);
set(b(3), 'facecolor', [[1 0 0]]);
set (b, 'edgecolor', [1,1,1])

legend('Reg.-True', ...
'Reg.-Outer Approx.', ...
'Reg.-Proposed (I=1)', ...
'Energy-True', ...
'Energy-Outer Approx.', ...
'Energy-Proposed (I=1)', ...
'fontsize',13.5, ...
'Location','NorthOutside', ...
'Orientation','vertical', ...
'NumColumns', 2, ...
'FontName', 'Times New Roman'); 
set(gca, "YGrid", "on");

% Set figure parameters
x1 = xlabel('Hour','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          
y1 = ylabel('Capacity (MW)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');

% Figure size
figureUnits = 'centimeters';
figureWidth = 15;
figureHeight = 10;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

% Axis properties
ax = gca;
ax.XLim = [0, 17];    
ax.FontSize = 13.5;
ax.XTick = [1:16];
ax.XTickLabel =  {'18','19','20','21','22','23','24','1','2','3','4','5','6','7','8','9'};
ax.FontName = 'Times New Roman';
set(gcf, 'PaperSize', [15, 10]);

saveas(gcf,'bids.pdf');
