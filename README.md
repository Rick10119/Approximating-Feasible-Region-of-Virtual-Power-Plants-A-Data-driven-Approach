# Approximating-Feasible-Region-of-Virtual-Power-Plants-A-Data-driven-Approach
This repository contains data and code related to my new research project on approximating the Energy-Regulation Feasible Region of Virtual Power Plants using a Data-driven Inverse Optimization Approach.

#### Overview:

- The `data_prepare` directory contains code that utilizes PJM electricity price data and a bidding model based on literature regarding electric vehicle fleet participation in energy and frequency markets to simulate optimal bidding results for 4000 electric vehicles on different dates. The generated data is stored in the `data_set` directory for reference.

- The `results` directory holds our research outcomes and visualization code.

- `main.m` and `main_opt.m` are the main programs for fitting the model parameters of the aggregated feasible region for 4000 EVs using inverse optimization on standard bidding data and optimal bidding data considering the coupling of bidding and power allocation. These programs call functions like `add_varDef_and_initVal` for variable definition and initialization, and functions starting with `add_` to add various constraints for the inverse optimization problem. We employ an iterative algorithm based on zeroth-order stochastic gradient descent (`inverse_problem.m`) to solve the inverse optimization problem. `bid_primal_problem.m` simulates optimal bidding results using the aggregated feasible region parameters to evaluate the effectiveness of the results obtained through our method.

Please note that this code repository represents an independent research project. The comments in the code are concise, and I expect readers to understand the implementation after reading our research paper available at [ResearchGate](https://www.researchgate.net/publication/377922537_Approximating_Energy-Regulation_Feasible_Region_of_Virtual_Power_Plants_A_Data-driven_Inverse_Optimization_Approach). Understanding the underlying principles may require referring to the paper rather than relying solely on the code comments.


### 代码库：数据驱动的虚拟电厂可行域聚合

这个代码库包含了我新研究项目的数据和代码，主题是利用数据驱动的逆向优化方法来近似虚拟电厂的能量-调频可行域。

#### 概述：

- `data_prepare` 文件夹包含的代码利用了PJM电价数据和基于文献的电动汽车车队参与能量和调频市场的投标模型，来模拟4000辆电动汽车在不同日期下的最优投标结果。生成的数据存放在 `data_set` 文件夹供参考。

- `results` 文件夹包含了我们的研究结果和可视化代码。

- `main.m` 和 `main_opt.m` 是用于在标准投标数据和考虑投标与功率分配耦合的最优投标数据集上通过逆向优化拟合4000辆电动汽车的聚合可行域模型参数的主程序。这些程序调用了 `add_varDef_and_initVal` 来定义变量并初始化，以及以 `add_` 开头的几个文件来添加逆向优化问题的各种约束。我们采用了基于零阶随机梯度下降的迭代算法 (`inverse_problem.m`) 来解决逆向优化问题。`bid_primal_problem.m` 利用聚合可行域参数模拟最优投标结果，用于评估我们方法得到的结果的效果。

请注意，这个代码库代表了一个独立的研究项目。代码中的注释比较简略，我希望读者在阅读我们在 [ResearchGate](https://www.researchgate.net/publication/377922537_Approximating_Energy-Regulation_Feasible_Region_of_Virtual_Power_Plants_A_Data-driven_Inverse_Optimization_Approach) 上发布的研究论文后能够理解代码的实现。理解背后原理可能需要参考论文，而不仅仅依靠代码注释。
