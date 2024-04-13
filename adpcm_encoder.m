function [index, err, prediction, predictor_matrix] = adpcm_encoder(partition, codebook, x, block_size, mu, p, A, gain, upper_bound)
% preallocations
N=numel(x);
d_q_n = zeros(1,N);
index = zeros(1,N);
prediction = zeros(size(x));
err = zeros(size(x));
predictor_matrix = zeros(p,N);
shift_reg = x(1:p)';

if block_size
    err_blocks = zeros(ceil(N/block_size),1);
    ind = 1;
end

for i=(p+1):N
    % adapt the learning rate (in block size jumps)
    if (mod(i,block_size)==0)
        err_block= d_q_n(i-block_size+1:min(N,i-1));
        err_blocks(ind) = mean(err_block.^2/block_size);
        if ind ~= 1
            mu = calculate_step_size(err_blocks(ind),err_blocks(ind-1),A,mu,gain,upper_bound);
        end
        ind = ind + 1;
    end
    % x_hat(i) = a_1*x(i-1) + a_2*x(i-2) + ... + a_p*x(i-p)
    prediction(i) = shift_reg * predictor_matrix(:,i);
    err(i) = x(i) - prediction(i);
    % quantize the error
    index(i) = sum(partition < err(i));
    d_q_n(i) = codebook(index(i)+1);
    % update weights based on d_q_n
    predictor_matrix(:,i+1) = predictor_matrix(:,i) + mu*d_q_n(i)*shift_reg';
    % generate new input to the predictor
    inp = d_q_n(i) + prediction(i);
    shift_reg = [inp shift_reg(1:p-1)];
end
end