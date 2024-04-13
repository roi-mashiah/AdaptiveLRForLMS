function [prediction,err,predictor_matrix,mu] = sgd_prediction(x,p,mu,block_size,A,gain,upper_bound)
% preallocation
N=numel(x);
prediction = zeros(size(x));
err = zeros(size(x));
predictor_matrix = zeros(p,N);
shift_reg = x(1:p)';

if block_size
    err_blocks = zeros(ceil(N/block_size),1);
    ind = 1;
end

for i=(p+1):N
    if (mod(i,block_size)==0)
        % adapt the learning rate (in block size jumps)
        err_block = err(i-block_size+1:min(N,i-1));
        err_blocks(ind) = mean(err_block.^2)/block_size;
        if ind > 1
            mu = calculate_step_size(err_blocks(ind),err_blocks(ind-1),A,mu,gain,upper_bound);
        end
        ind = ind + 1;
    end
    
    % x_hat(i) = a_1*x(i-1) + a_2*x(i-2) + ... + a_p*x(i-p)
    prediction(i) = shift_reg * predictor_matrix(:,i);
    err(i) = x(i) - prediction(i);
    % update weights
    predictor_matrix(:,i+1) = predictor_matrix(:,i) + mu*err(i)*shift_reg';
    % increment the sr
    shift_reg = [x(i) shift_reg(1:p-1)];
end
end

