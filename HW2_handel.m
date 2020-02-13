clear all; close all; clc;

%% Signal creation
load handel % load file
v=y'/2; % this is our signal, transpose to get column vector
n=length(v); % number of samples = 73,113
L=n/Fs; % length of signal

t=(1:n)/Fs; % time vector 

k=(1/L)*[0:(n-1)/2 -(n-1)/2:-1]; % k for odd number of points
ks=fftshift(k); % shifted frequency domain

tslide=0:0.5:L; % sliding window from 0 to L with time step 0.05

%% plot signal 
vt=fft(v);

figure(1)
subplot(2,1,1)
plot((1:length(v))/Fs,v); % plot of our signal 
set(gca,'Fontsize',[12]), xlabel('Time [sec]'), ylabel('Amplitude')
xlim([0 9]),title('Signal of Interest, v(n)');
subplot(2,1,2)
plot(ks,abs(fftshift(vt))/max(abs(vt))); 
set(gca,'Fontsize',[12]), xlabel('frequency (\omega)'), ylabel('FFT(v)')
title('Fourier Transform of v(n)')
vt=fft(v);

figure(1)
subplot(3,1,1) 
plot((1:length(v))/Fs,v) 
set(gca,'Fontsize',[14]), xlabel('Time [sec]'), ylabel('Amplitude')
xlim([0 9]);

subplot(3,1,2) 
plot(ks,abs(fftshift(vt))/max(abs(vt))); 
set(gca,'Fontsize',[14])
xlabel('frequency (\omega)'), ylabel('FFT(v)')

p8 = audioplayer(v,Fs); % Handel's song
playblocking(p8);

%% plot signal with filter
figure(2) 
width=[0.2 1 5]; % show different width (window size)
for j=1:3
    g=0.4*exp(-width(j)*(t-4).^2); % make a gaussian
    subplot(3,1,j)
    plot(t,v), hold on % plot signal in time
    plot(t,g,'r','Linewidth',[1.5]) % plot filter 
    set(gca,'Fontsize',[14]) % plot together
    ylabel('Amplitude'); xlabel('Time [sec]')
    xlim([0 9]);
end

%% mexican hat window
a=10;b=10; % set widths
g2=0.4*(1-b*(t-4).^2).*exp(-a*(t-4).^2); % create filter 
plot(t,v), hold on
plot(t,g2,'r','Linewidth',[1.5])
set(gca,'Fontsize',[14])
ylabel('Amplitude'); xlabel('Time [sec]')
xlim([0 9]);


%% slide window
a=500; b=1000; % widths
vgt_spec=[]; % spectrogram data matrix

for j=1:length(tslide)
    g=exp(-a*(t-tslide(j)).^2); % Gaussian filter 
    g=(1-b*(t-tslide(j)).^2).*exp(-a*(t-tslide(j)).^2); % mexican hat
    vg=g.*v; % multiply signal by filter
    vgt=fft(vg); % fourier transform
    vgt_spec=[vgt_spec; abs(fftshift(vgt))]; % build spectrogram matrix
    
    subplot(3,1,1), plot(t,v,t,g,'r') 
    xlabel('Time [sec]'); ylabel('Amplitude');
    subplot(3,1,2), plot(t,vg)
    xlabel('Time [sec]'); ylabel('Amplitude');
    subplot(3,1,3), plot(ks,abs(fftshift(vgt))/max(abs(vgt)))
    xlabel('Frequency [Hz]'); ylabel('Amplitude');
    drawnow
    pause(0.1)
end

%% spectogram
% spectrogram - k content stacked together 
figure(5)
pcolor(tslide,ks,vgt_spec.'), shading interp
%set(gca,'Ylim',[100 600],'Fontsize',[14])
xlabel('Time [sec]'), ylabel('Frequency [Hz]')
ylim([0 1200]);
colormap(hot)

%% shannon filter 
a=5000; % width
len=5; % length of slide
vgt_spec_2=[]; % spectrogram data matrix
overlap=round(a/len); % set center of shannon window
slide=1:overlap:length(t); % where to slide
for j=1:length(slide)
    shan_filt=shan_step(t,slide(j),a); % call step function
    vg=shan_filt.*v; % multiply signal by filter
    vgt=fft(vg); % fourier transform
    vgt_spec_2=[vgt_spec_2; abs(fftshift(vgt))]; % build spectrogram matrix
end

%spectrogram
figure(6)
pcolor(slide,ks,vgt_spec_2.'), shading interp
%set(gca,'Ylim',[100 600],'Fontsize',[14])
xlabel('Time [sec]'), ylabel('Frequency [Hz]')
ylim([0 1200]);
colormap(hot)

function shan=shan_step(t,c,a)
out=zeros(1,length(t))
if (c+a)>length(t)
    out(1:(c-a))=0;
    out((c-a):length(t))=1;
elseif c>a
    out(1:(c-a))=0;
    out((c-a):(c+a))=1;
    out((c+a):length(t))=0;
else
    out(1:(c+a))=1;
    out((c+a):length(t))=0;
end
shan=out;