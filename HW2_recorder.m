clear all; close all; clc;

tr_rec=14; 
y=audioread('music2.wav');
Fs=length(y)/tr_rec; 
plot((1:length(y))/Fs,y);
xlabel('Time [sec]'); ylabel('Amplitude');
title('Mary had a little lamb (recorder)'); drawnow
p8=audioplayer(y,Fs); playblocking(p8);
R=y'/2;
n=length(R);
L=n/Fs; % 14 time units

t=(1:n)/Fs;
k=(1/L)*[0:(n/2-1) -n/2:-1]; % k for even number of points
ks=fftshift(k); % shifted frequency domain

tslide=0:0.1:L; % sliding window from 0 to L with time step 0.1
%% slide window
a=500;
Rgt_spec=[]; % spectrogram data matrix

for j=1:length(tslide)
    g=exp(-a*(t-tslide(j)).^2); % Gaussian filter 
    Rg=g.*R; % multiply signal by filter
    Rgt=fft(Rg); % fourier transform
    Rgt_spec=[Rgt_spec; abs(fftshift(Rgt))];
    
    subplot(3,1,1), plot(t,P,t,g,'r') 
    xlabel('Time [sec]'); ylabel('Amplitude');
    subplot(3,1,2), plot(t,Pg)
    xlabel('Time [sec]'); ylabel('Amplitude');
    subplot(3,1,3), plot(ks,abs(fftshift(Pgt))/max(abs(Pgt)))
    xlabel('Frequency [Hz]'); ylabel('Amplitude');
    drawnow
    pause(0.1)
end

%% spectogram
% spectrogram - k content stacked together 
figure(5)
pcolor(tslide,ks,Rgt_spec.'), shading interp
%set(gca,'Ylim',[100 600],'Fontsize',[14])
xlabel('Time [sec]'), ylabel('Frequency [Hz]')
ylim([700 1100]);
colormap(hot)