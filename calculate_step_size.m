function [new_mu] = calculate_step_size(curr_err, prev_err, A, mu, gain, upper_bound)
new_mu = mu;
d = curr_err - prev_err;
if (d < A) && ((1+gain)*mu < upper_bound)
    new_mu = (1+gain)*mu;
elseif (d > A) && (d < 3*A)
    new_mu = (1-gain)*mu;
elseif d > 3*A
    new_mu = mu*gain;
end
end
