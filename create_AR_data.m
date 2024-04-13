function [ar_mashup, coeff_mat] = create_AR_data(T,fs)
% create_AR_data generates an AR(2) process w/ time varying coeffs
N=fs*T;
ar_mashup=zeros(N,1);
coeff_mat = zeros(T,3);
for i=1:T
    % generate coefficients that promise convergence
    a2 = -1 + 2*rand;
    a1 = -1 + 2*rand;
    while (((a1+a2) < -1) || ((a2-a1) < -1))
        a1 = -1 + 2*rand;
        a2 = -1 + 2*rand;
    end
    % monic tf - y_n = x_n + a1*x_n-1 + a2*x_n-2
    coeff_mat(i,:) = [1,a1,a2];
    curr = generate_AR_process(fs,coeff_mat(i,:))';
    ar_mashup((i-1)*fs+1:fs*i) = curr;
end
% normalize the output
ar_mashup = ar_mashup/max(ar_mashup);
end

