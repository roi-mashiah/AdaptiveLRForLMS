clearvars; close all
%% AR2 data
T=10; fs=2250;
% create non stationary data - patched AR(2) w/ random coefficients
[ar_mashup,coeff_mat_ar] = create_AR_data(T,fs);
% x_n + a_1*x_n-1 + a_2*x_n-2 = w_n
coeffs = -coeff_mat_ar(:,2:end);

% predict using LMS\SGD (clean prediction) w/ const. mu and adaptive mu
p = [2 2 5];
A = [1e-3 1e-5 1e-3];
g = 0.2;
mu = [0.001 3 0.01];
bound = [1 3 1];
block_size = round((0.1)*fs); % 0.1 sec - 10 iterations per coefficient
for m=1:3
    % constant step size
    [~,ar_err_c,coeff_c] = sgd_prediction(ar_mashup,p(m),mu(m),0,0,0,0);
    % adaptive step size
    [~,ar_err_a,coeff_a] = sgd_prediction(ar_mashup,p(m),mu(m),block_size,A(m),g,bound(m));

    plot_mse_convergence(T,fs,ar_mashup,ar_err_c,coeff_c,ar_err_a,coeff_a,coeffs);
    d_ar_a = mean(ar_err_a.^2)/numel(ar_err_a)
    d_ar_c = mean(ar_err_c.^2)/numel(ar_err_c)
end
%% audio data
p=8;
files = dir(strcat("LibriSpeech\test-clean\121\","**\*.flac"));
distortion_a = zeros(length(files),1);
distortion_c = distortion_a;
initial_mu = 0.001;
for f=1:length(files)
    file_name = fullfile(files(f).folder,files(f).name);
    [y,fs] = audioread(file_name);
    block_size = fs*30e-3;
    [pred_speech_a,speech_err_a,coeff_speech_a,mu_aa] = sgd_prediction(y,p,initial_mu,block_size,A(1),g,1);
    [pred_speech_c,speech_err_c,coeff_speech_c] = sgd_prediction(y,p,initial_mu,0,0,0,0);
%     plot_mse_convergence(numel(y)/fs,fs,y,speech_err_c,coeff_speech_c,speech_err_a,coeff_speech_a,0);
    distortion_a(f) = mean(speech_err_a.^2)/numel(speech_err_a);
    distortion_c(f) = mean(speech_err_c.^2)/numel(speech_err_c);
end

figure
bar([distortion_a distortion_c]);grid
ylabel("MSE")
xlabel("File Index")
title(strcat("MSE for Audio Data with p = ",num2str(p)))
legend(["Adaptive \mu", "Constant \mu"], 'Location','best')
%% ADPCM
% Encoder
index = zeros(3,30,524320); % one of M levels for each file - plug number is maximal length
distortion = zeros(3,30);
% parameters for LMS
mu = 0.01; % initial step size
p = 8; % p samples to the past
gain = 0.1;
ub = 1;
A=1e-12;

files = dir(strcat("LibriSpeech\test-clean\908\","**\*.flac"));

% get a sample error distribution for lloyds
file_name = fullfile(files(1).folder,files(1).name);
[y,fs] = audioread(file_name);
block_size = fs*30e-3;
len = length(y);
[~,speech_err_a] = sgd_prediction(y,p,mu,block_size,A,gain,1);

for M=3:5
    % create quantization scheme using lloyds algorithm 
    [partition,codebook] = lloyds(speech_err_a,2^M);
    for f=2:31
        file_name = fullfile(files(f).folder,files(f).name);
        [y,fs] = audioread(file_name);
        block_size = fs*30e-4;
        len = length(y);
        index(M-2,f-1,1:len) = adpcm_encoder(partition,codebook,y,block_size,mu,p,A,gain,ub);
    end 
end

% Decoder
decoded_audio = zeros(size(index));

for M=3:5
    % create quantization scheme using lloyds algorithm
    [partition,codebook] = lloyds(speech_err_a,2^M);
    for f=2:31
        file_name = fullfile(files(f).folder,files(f).name);
        [y,fs] = audioread(file_name);
        block_size = fs*30e-4;
        len = length(y);
        decoded_audio(M-2,f-1,1:len) = adpcm_decoder(codebook, index(M-2,f-1,1:len), block_size,mu,p,A,gain,ub);
        D = y - squeeze(decoded_audio(M-2,f-1,1:len));
        distortion(M-2,f-1) = mean(D.^2)/len;
    end 
end
%% distortions as a function of M
figure
bar(categorical([3, 4, 5]),distortion);grid
ylabel("Distortion")
xlabel("File Index")
title(strcat("Distortion for Audio Data with p = ",num2str(p)))
%% one file example
figure;
t = 0:1/fs:(len-1)/fs;
m_3 = squeeze(decoded_audio(1,end,1:len));
m_4 = squeeze(decoded_audio(2,end,1:len));
m_5 = squeeze(decoded_audio(3,end,1:len));
plot(t,y)
hold on
plot(t,m_5)
plot(t,m_4)
plot(t,m_3)
grid
xlabel("T[sec]")
title("Original Audio VS Reconstructed Audio")
legend(["original","M=5","M=4","M=3"],'Location','best')
%% play the sounds to hear the difference
% original
soundsc(y,fs)
pause(len/fs);
% M=3
soundsc(m_3,fs)
pause(len/fs)
% M=4
soundsc(m_4,fs)
pause(len/fs)
% M=5
soundsc(m_5,fs)

