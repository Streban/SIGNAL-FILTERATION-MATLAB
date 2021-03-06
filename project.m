clc;clear
%Task 1
real = table2array(readtable('Real(cvs).csv'));
img = table2array(readtable('Imaginary(cvs).csv'));
fs=44100;
len_img = length(img);
len_real = length(real);
freq_response = zeros(1,len_img);
for i=1:len_img
    if i<=len_real
        freq_response(i)=complex(real(i),img(i));
    else
        freq_response(i)=complex(0,img(i)); %For no values of real in csv, 0 supposed
    end
end

%Importing the filter variables
Num = load('Num.mat'); %Lowpass filter with cutoff 3500 Hz
Num = Num.Num;
Num2 = load('Num2.mat'); %Highpass filter with cutoff 3500 HZ
Num2 = Num2.Num2;
G = load('G.mat'); %Low pass IIR Filter with normalised freq cutoff = 0.35
G = G.G;
G2 = load('G2.mat'); %High pass IIR Filter with normalised freq cutoff = 0.35
G2=G2.G2;
SOS = load('SOS.mat');
SOS=SOS.SOS; %This is done as variable loaded is in struct data type
SOS2 = load('SOS2.mat');
SOS2=SOS2.SOS2;
%Task 2
%Shifting the frequency response to -pi to pi
n = length(freq_response);
f = (0:n-1)*fs/n;   %formula for it from google
power_ori = abs(freq_response).^2/n; %For original
n=length(freq_response);
y = fftshift(freq_response);
fshift = (-n/2:n/2-1)*pi/n;     % shifting formula form -pi to pi
powershift = abs(y).^2/n; %magnitude specturm
figure
subplot(211)
plot(fshift,powershift)
title('Magnitude Response of original Signal')
phase = angle(y);
subplot(212)
plot(fshift,phase)
title('Phase Response of original signal')




%Task 3
% filtering is done in time domain

y_inv = ifft(y); %Data in time domain  tranfer in time domain to filter
figure
subplot(311)
plot(fshift,abs(fft(y_inv)))
title('Original')
noise = filter(Num,1,y_inv); %Num is lowpass filtered variable
subplot(312)
plot(fshift,abs(fft(noise)))
title('Noise')
filtered = filter(Num2,1,y_inv); %Num1 is highpass filtered value
subplot(313)
plot(fshift,abs(fft(filtered)))
title('Filtered')
%Storing signals
audiowrite('noisy_signal_6.wav',abs(noise),fs);
audiowrite('filtered_speech_6.wav',abs(filtered),fs);
%Plotting magnitude and phase responses of filtered and unfiltered signal
figure
subplot(221)
plot(fshift,powershift)
title('Magnitude Response of original Signal')
phase = angle(y);  %for phase built in
subplot(222)
plot(fshift,phase)
title('Phase Response of original signal')
power_filtered = abs(filtered).^2/n;    %formula for magnitutde specturm
phase_filtered = angle(filtered);     
subplot(223)
plot(fshift,power_filtered)
title('Magnitude Spectrum of Filtered')
subplot(224)
plot(fshift,phase_filtered)
title('Phase Spectrum of Filtered')







%Task 4

[b,a]=sos2tf(SOS,G); %Converting these variables so they can be passed to filter function
[b2,a2]=sos2tf(SOS2,G2);
tone1 = filter(b,a,filtered);   
tone2 = filter(b2,a2,filtered);
figure
subplot(211)
plot(fshift,abs(fft(tone1)))
title('Tone 1')
subplot(212)
plot(fshift,abs(fft(tone2)))
title('Tone 2')
%Storing tones
audiowrite('filtered_tone_1_6.wav',abs(tone1),fs);
audiowrite('filtered_tone_2_6.wav',abs(tone2),fs);
%Phase graphs of tones
subplot(211)
plot(fshift,angle(tone1))
title('Phase of tone 1')
subplot(212)
plot(fshift,angle(tone2))
title('Phase of tone 2')
%Proving tones are sine waves
figure
subplot(211)
plot(abs(tone1(20:40)))
title('Time Domain Tone 1 zoomed in')
subplot(212)
plot(abs(tone2(20:40)))
title('Time Domain Tone 2 zoomed in')
%Reporting SNR
disp('SNR of tone 1:')   %snr builtin function
disp(snr(tone1,noise))
disp('SNR of tone 2:')
disp(snr(tone2,noise))
disp('SNR of filtered signal:')
disp(snr(filtered,noise))
disp('SNR of unfiltered:')
disp(snr(y_inv,noise))