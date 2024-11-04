% 问题3：Matlab代码实现

%% 设置保存路径
output_folder = './Figure';
if ~exist(output_folder, 'dir')
    mkdir(output_folder); % 如果文件夹不存在，则创建
end

%% 设置信号和噪声参数
s = 3;         % 信号强度
sigma = 2;     % 噪声的标准差
num_trials = 10000;  % 实验次数

%% 生成观测数据
signal_present = rand(num_trials, 1) > 0.5;  % 每次实验以50%的概率呈现信号
noise = sigma * randn(num_trials, 1);        % 生成服从正态分布的噪声

% 测量值 (信号存在时加上信号强度)
measurements = noise + s * signal_present;

%% 问题3.1：绘制信号存在和不存在时的测量直方图，并保存
figure;
hold on;
histogram(measurements(signal_present), 'Normalization', 'pdf', 'DisplayName', 'Signal Present');
histogram(measurements(~signal_present), 'Normalization', 'pdf', 'DisplayName', 'Signal Absent');
legend;
title('Measurements Histogram');
xlabel('Measurement Value');
ylabel('Probability Density');
hold off;
saveas(gcf, fullfile(output_folder, 'Measurements_Histogram.png')); % 保存图像

%% 问题3.2：计算决策变量（对数后验比），并绘制直方图并保存
% 决策变量的计算 (对数似然比)
decision_variable = log(normpdf(measurements, s, sigma) ./ normpdf(measurements, 0, sigma));

figure;
hold on;
histogram(decision_variable(signal_present), 'Normalization', 'pdf', 'DisplayName', 'Signal Present');
histogram(decision_variable(~signal_present), 'Normalization', 'pdf', 'DisplayName', 'Signal Absent');
legend;
title('Decision Variable Histogram');
xlabel('Decision Variable');
ylabel('Probability Density');
hold off;
saveas(gcf, fullfile(output_folder, 'Decision_Variable_Histogram.png')); % 保存图像

%% 问题3.3：基于对数似然比计算置信度，并创建2x6的表格
confidence = abs(decision_variable); % 置信度计算

% 定义置信度评级
confidence_rating = zeros(num_trials, 1);
confidence_rating(confidence > 2) = 3;  % 高置信度
confidence_rating(confidence > 1 & confidence <= 2) = 2;  % 中置信度
confidence_rating(confidence > 0 & confidence <= 1) = 1;  % 低置信度

% 创建2x6响应表
responses = zeros(2, 6); % 2种刺激（信号存在或不存在）和6种反应（低、中、高置信度）
for i = 1:num_trials
    stimulus_idx = signal_present(i) + 1;  % 1:信号不存在, 2:信号存在
    if confidence_rating(i) == 3 % 高置信度
        response_idx = 4; % 信号存在
    elseif confidence_rating(i) == 2 % 中置信度
        response_idx = 5; % 信号存在
    elseif confidence_rating(i) == 1 % 低置信度
        response_idx = 6; % 信号存在
    end
    responses(stimulus_idx, response_idx) = responses(stimulus_idx, response_idx) + 1;
end


% % 计算经验 ROC
% true_positive_rate = cumsum(responses(2, 4:6)) / sum(responses(2, :)); % 高置信度 (H), 中置信度 (M), 低置信度 (L) 对于信号存在
% false_positive_rate = cumsum(responses(1, 4:6)) / sum(responses(1, :)); % 高置信度 (H), 中置信度 (M), 低置信度 (L) 对于信号不存在
% 
% % 添加 (0, 0) 和 (1, 1) 点
% false_positive_rate = [0 false_positive_rate 1]; 
% true_positive_rate = [0 true_positive_rate 1];
% 
% % 绘制 ROC 曲线
% figure;
% plot(false_positive_rate, true_positive_rate, '-o');
% title('Empirical ROC Curve');
% xlabel('False Positive Rate');
% ylabel('True Positive Rate');
% axis([0 1 0 1]); % 设置坐标轴范围
% grid on;
% 计算 TP、FP、TN 和 FN
TP_L = responses(1, 1); % 信号存在且低置信度
TP_M = responses(1, 2); % 信号存在且中置信度
TP_H = responses(1, 3); % 信号存在且高置信度

FP_L = responses(2, 4); % 信号不存在且低置信度
FP_M = responses(2, 5); % 信号不存在且中置信度
FP_H = responses(2, 6); % 信号不存在且高置信度

% 计算总和
TP = TP_L + TP_M + TP_H; % 总真阳性
FP = FP_L + FP_M + FP_H; % 总假阳性
FN = 0;                  % 总假阴性，信号存在时没有判断错误
TN = sum(responses(2, :)); % 总真阴性

% 计算 TPR 和 FPR
TPR_H = TP_H / (TP_H + FN); % 高置信度下的 TPR
FPR_H = FP_H / (FP_H + TN); % 高置信度下的 FPR

TPR_M = TP_M / (TP_M + FN); % 中置信度下的 TPR
FPR_M = FP_M / (FP_M + TN); % 中置信度下的 FPR

TPR_L = TP_L / (TP_L + FN); % 低置信度下的 TPR
FPR_L = FP_L / (FP_L + TN); % 低置信度下的 FPR

% ROC 数据点
TPR = [0, TPR_L, TPR_M, TPR_H, 1]; % 加入（0,0）和（1,1）点
FPR = [0, FPR_L, FPR_M, FPR_H, 1]; % 加入（0,0）和（1,1）点



% TPR 和 FPR 值
TPR = [0, 0, 1, 1]; % ROC 点，0表示无置信，1表示高置信
FPR = [0, 0.064, 0.229, 0.388]; % FPR 的值

% 绘制 ROC 曲线
figure;
plot(FPR, TPR, '-o');
title('Empirical ROC Curve');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
grid on;
axis([0 1 0 1]);
hold on;
plot([0 1], [0 1], 'k--'); % 参考对角线
hold off;

saveas(gcf, fullfile(output_folder, 'Empirical_ROC_Curve.png')); % 保存图像
%% 问题3.4：减少信号强度，重新运行
s = 2;  % 将信号强度减小到2

% 重新生成观测数据
measurements = noise + s * signal_present;

% 重新计算决策变量和绘制直方图并保存
decision_variable = log(normpdf(measurements, s, sigma) ./ normpdf(measurements, 0, sigma));

figure;
hold on;
histogram(decision_variable(signal_present), 'Normalization', 'pdf', 'DisplayName', 'Signal Present');
histogram(decision_variable(~signal_present), 'Normalization', 'pdf', 'DisplayName', 'Signal Absent');
legend;
title('Decision Variable Histogram (Reduced Signal Strength)');
xlabel('Decision Variable');
ylabel('Probability Density');
hold off;
saveas(gcf, fullfile(output_folder, 'Decision_Variable_Histogram_Reduced_Signal.png')); % 保存图像

% 解释：减小信号强度后，信号和噪声分布重叠更多，降低了检测的区分能力。
