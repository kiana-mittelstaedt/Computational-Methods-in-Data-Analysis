% music classification 

clear all; close all; clc;

%% training data
%audio read 
Fs=44100; % set sampling rate - was the same for all bands
idx=[1 3 5 7 8 10 12 13 15 17 18 19 21 23 24 25 27 29 31 32]; % 20 random indices
for i=1:length(idx)
    clip_num=idx(i);
    start=(5*(clip_num-1)+1); stop=(5*clip_num)+1; 
    sample=[(start*Fs) (stop*Fs)]; % take 20 5-second clips of each song

    % goo goo dolls
    slide=audioread('GooSlide.wav',sample);
    slide=slide(:,1); slide=slide(1:5:length(slide)); % re-sample
    samp_slide(:,:,i)=slide;
    iris=audioread('GooIris.wav',sample);
    iris=iris(:,1); iris=iris(1:5:length(iris));
    samp_iris(:,:,i)=iris;
    giveBit=audioread('GooGiveBit.wav',sample);
    giveBit=giveBit(:,1); giveBit=giveBit(1:5:length(giveBit));
    samp_giveBit(:,:,i)=giveBit;
    
    % eminem
    woutMe=audioread('EminemWithoutMe.wav',sample);
    woutMe=woutMe(:,1); woutMe=woutMe(1:5:length(woutMe));
    samp_woutMe(:,:,i)=woutMe;
    tillCollap=audioread('EminemTillCollapse.wav',sample);
    tillCollap=tillCollap(:,1); tillCollap=tillCollap(1:5:length(tillCollap));
    samp_tillCollap(:,:,i)=tillCollap;
    loseSelf=audioread('EminemLoseYourself.wav',sample);
    loseSelf=loseSelf(:,1); loseSelf=loseSelf(1:5:length(loseSelf));
    samp_loseSelf(:,:,i)=loseSelf;
    
    % johnny cash
    walkLine=audioread('JohnnyWalkLine.wav',sample);
    walkLine=walkLine(:,1); walkLine=walkLine(1:5:length(walkLine));
    samp_walkLine(:,:,i)=walkLine;
    ringFire=audioread('JohnnyRingFire.wav',sample);
    ringFire=ringFire(:,1); ringFire=ringFire(1:5:length(ringFire));
    samp_ringFire(:,:,i)=ringFire;
    prisonBlues=audioread('JohnnyPrisonBlues.wav',sample);
    prisonBlues=prisonBlues(:,1); prisonBlues=prisonBlues(1:5:length(prisonBlues));
    samp_prisonBlues(:,:,i)=prisonBlues;
end

%% spectrograms
% we have 20 clips of 9 songs --> 180 total clips
for i=1:180
    if i<21
        clip=samp_slide(:,:,i)'/2; % take each clip as a signal
    elseif i<41
        clip=samp_giveBit(:,:,(i-20))'/2;
    elseif i<61
        clip=samp_iris(:,:,(i-40))'/2;
    elseif i<81
        clip=samp_woutMe(:,:,(i-60))'/2;
    elseif i<101
        clip=samp_tillCollap(:,:,(i-80))'/2;
    elseif i<121
        clip=samp_loseSelf(:,:,(i-100))'/2;
    elseif i<141
        clip=samp_ringFire(:,:,(i-120))'/2;
    elseif i<161
        clip=samp_prisonBlues(:,:,(i-140))'/2;
    else
        clip=samp_walkLine(:,:,(i-160))'/2;
    end
    n=length(clip); L=n/Fs; % this is from Homework 2 - spectrogram
    t=(1:n)/Fs; tslide=0:0.3:L;
    k=(1/L)*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);
    spec=[];
    for j=1:length(tslide)
        g=exp(-100*(t-tslide(j)).^2); % Gabor window filter
        clipg=g.*clip;
        clipgt=fft(clipg);
        spec=[spec; abs(fftshift(clipgt))];
    end
    train_spec_test1(:,:,i)=spec'; % build spectrogram matrix 
end
%%
train_spec_test1=reshape(train_spec_test1,44101*4,180); % reshape so each column is a song spectrogram
train_spec_test1=train_spec_test1-mean(train_spec_test1); % subtract the mean
%svd 
[u,s,v]=svd(train_spec_test1,'econ'); % reduced svd
       
%% test data 
%audio read 
idx=[5 15 18 22 28]; % random indices
for i=1:length(idx)
    clip_num=idx(i);
    start=(5*(clip_num-1)+1); stop=(5*clip_num)+1;
    sample=[(start*Fs) (stop*Fs)];
    
    % goo goo dolls
    broadway=audioread('GooBroadway.wav',sample);
    broadway=broadway(:,1); broadway=broadway(1:5:length(broadway));
    samp_broadway(:,:,i)=broadway;
    
    % eminem
    godzilla=audioread('EminemGodzilla.wav',sample);
    godzilla=godzilla(:,1); godzilla=godzilla(1:5:length(godzilla));
    samp_godzilla(:,:,i)=godzilla;
    
    % johnny cash
    cokeBlues=audioread('JohnnyCocaineBlues.wav',sample);
    cokeBlues=cokeBlues(:,1); cokeBlues=cokeBlues(1:5:length(cokeBlues));
    samp_cokeBlues(:,:,i)=cokeBlues;
end

%% spectrograms
for i=1:15
    if i<6
        clip=samp_broadway(:,:,i)'/2;
    elseif i<11
        clip=samp_godzilla(:,:,(i-5))'/2;
    else
        clip=samp_cokeBlues(:,:,(i-10))'/2;
    end
    n=length(clip); L=n/Fs;
    t=(1:n)/Fs; tslide=0:0.3:L;
    k=(1/L)*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);
    spec=[];
    for j=1:length(tslide)
        g=exp(-100*(t-tslide(j)).^2);
        clipg=g.*clip;
        clipgt=fft(clipg);
        spec=[spec; abs(fftshift(clipgt))];
    end
    test_spec_test1(:,:,i)=spec';
end

test_spec_test1=reshape(test_spec_test1,44101*4,15);

% project onto new basis - training data 
ut=u';
test_proj=ut*test_spec_test1;

%% classify 
group=ones(60,1); % goo goo dolls
group(61:120)=2; % eminem
group(121:180)=3; % johnny cash

rank=100;
test1Class=classify(test_proj(1:rank,:)',v(:,1:rank),group); % use first 100
plot(test1Class)
