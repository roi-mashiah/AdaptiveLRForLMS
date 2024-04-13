function [x_hat] = adpcm_decoder(codebook, levels, block_size, mu, p, A, gain, upper_bound)
quanterr = codebook(levels+1);
N=numel(levels);
shift_reg = zeros(p, 1);
x_hat = zeros(1, N);
out = x_hat;
predictor_matrix = zeros(p,N);

if block_size
    err_blocks = zeros(ceil(N/block_size),1);
    ind = 1;
end

for i = 1:N
    % adapt the learning rate (in block size jumps)
    if (mod(i,block_size)==0)
        err_block = quanterr(i-block_size+1:min(N,i-1));
        err_blocks(ind) = mean(err_block.^2)/block_size;
        if ind > 1
            mu = calculate_step_size(err_blocks(ind),err_blocks(ind-1),A,mu,gain,upper_bound);
        end
        ind = ind + 1;
    end
    out(i) =  predictor_matrix(:,i)' * shift_reg;
    x_hat(i) = quanterr(i) + out(i);
    predictor_matrix(:,i+1) = predictor_matrix(:,i) + mu*quanterr(i)*shift_reg;
    % renew the estimated output
    shift_reg = [x_hat(i); shift_reg(1:p-1)];
end
end

