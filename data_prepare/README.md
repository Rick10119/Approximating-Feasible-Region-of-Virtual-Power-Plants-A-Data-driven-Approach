### Data Preparation for Electric Vehicle Fleet Bidding Simulation

The code in the `data_prepare` directory is primarily used to simulate the optimal bidding results of 4000 electric vehicles on different dates using PJM electricity price data and a bidding model based on the participation of electric vehicle fleets in energy and frequency markets as outlined in the literature.

#### Files Overview:

- `main_parameter_generate.m`: This program reads market-related data (utilizing `generate_market_parameter.m`, which includes market prices and RegD signal historical data) and parameters of the EV fleet (using `generate_ev_parameter.m`).

- `generate_bids.m`: This script uses the above parameters to generate optimal bidding structures using the original high-dimensional parameters (4000 EVs).

- `generate_bids_opt.m`: This script represents the coupling of bidding and power decomposition in the model (referencing our previous work:  
  - R. Lyu, H. Guo, K. Zheng, M. Sun, and Q. Chen, "Co-Optimizing Bidding and Power Allocation of an EV Aggregator Providing Real-Time Frequency Regulation Service," in IEEE Transactions on Smart Grid, vol. 14, no. 6, pp. 4594-4606, Nov. 2023, doi: 10.1109/TSG.2023.3252664.)

Feel free to explore the code and adapt it for your own research purposes. If you have any questions or need further clarification, please don't hesitate to reach out.

### 电动汽车车队投标模拟数据准备

`data_prepare` 文件夹中的代码主要用于利用PJM电价数据和基于文献的电动汽车车队参与能量和调频市场的投标模型来模拟4000辆电动汽车在不同日期下的最优投标结果。

#### 文件概述：

- `main_parameter_generate.m`：该程序用于读取市场相关数据（使用`generate_market_parameter.m`，包括市场价格和RegD信号历史数据）以及EV车队的参数（使用`generate_ev_parameter.m`）。

- `generate_bids.m`：该脚本利用上述参数生成利用原始高维参数（4000辆EV）的最优投标结构。

- `generate_bids_opt.m`：该脚本代表模型中考虑投标和功率分解的耦合（参考我们之前的工作：
  - R. Lyu, H. Guo, K. Zheng, M. Sun 和 Q. Chen, "Co-Optimizing Bidding and Power Allocation of an EV Aggregator Providing Real-Time Frequency Regulation Service," 发表于 IEEE Transactions on Smart Grid, vol. 14, no. 6, pp. 4594-4606, 2023年11月, doi: 10.1109/TSG.2023.3252664.)

欢迎查看代码并根据您自己的研究目的进行调整。如有任何问题或需要进一步解释，请随时联系。