function [] = plot_mse_convergence(T,fs,input_data,pred_err_const, coeff_const, pred_err_adpt, coeff_adpt, ref)
p = size(coeff_const,1);
t=0:(1/fs):T;
t=t(1:numel(input_data));
c_interp = zeros(numel(input_data),2);
% plot input data
figure;
plot(t,input_data);
xlabel("T [sec]")
title("Input data")
grid;

% plot mse vs time constant step size
figure;
subplot(221)
plot(t,((pred_err_const.^2)/numel(pred_err_const)),"color","magenta");grid;
ylabel("MSE");
xlabel("T[sec]")
title("MSE vs time - Constant \mu")

subplot(223)
plot(t,coeff_const(:,1:end-1)');grid;
if ~isscalar(ref)
    for i=1:size(c_interp,1)-1
        c_interp(i,:) = ref(floor(i/fs)+1,:);
    end
    hold on
    plot(t,c_interp);
end
ylabel("Coefficients");
xlabel("T[sec]")
title("Coefficients vs time")

legend_str = string();
for i=1:p
    legend_str(i) = strcat("a_{",num2str(i),"}");
end
legend(legend_str,'Location','best')
hold off
% plot mse vs time - adaptive step size
subplot(222)
plot(t,((pred_err_adpt.^2)/numel(pred_err_adpt)),"Color","cyan");
grid;
ylabel("MSE");
xlabel("T[sec]")
title("MSE vs time - Adaptive \mu")
subplot(224)

plot(t,coeff_adpt(:,1:end-1)');grid;
if ~isscalar(ref)
    hold on
    plot(t,c_interp);
end
ylabel("Coefficients");
xlabel("T[sec]")
title("Coefficients vs time")
legend(legend_str,'Location','best')
hold off
end

