function [x] = generate_AR_process(fs,coeff)
n = 0:(1/fs):1;
w = randn(size(n))*sqrt(0.1);
x=filter(1,coeff,w); % coeff is the IIR filter coefficients
x=x(1:end-1);
end

