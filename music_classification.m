% music classification 

clear all; close all; clc;

%% training data
%audio read 
Fs=44100; % set sampling rate - was the same for all bands
idx=[1 3 5 7 8 10 12 13 15 17 18 19 21 23 24 25 27 29 31 32]; % 20 random indices
for i=1:length(idx)
    num=idx(i);
    mult1=(5*(num-1)+1); mult2=(5*num)+1; 
    sample=[(mult1*Fs) (mult2*Fs)]; % take 20 5-second clips of each song

    % blink 182
    allSmall=audioread('BlinkAllSmall.wav',sample);
    allSmall=allSmall(:,1); allSmall=allSmall(1:5:length(allSmall));
    samp_allSmall(:,:,i)=allSmall;
    firstDate=audioread('BlinkFirstDate.wav',sample);
    firstDate=firstDate(:,1); firstDate=firstDate(1:5:length(firstDate));
    samp_firstDate(:,:,i)=firstDate;
    anthemP2=audioread('BlinkAnthemP2.wav',sample);
    anthemP2=anthemP2(:,1); anthemP2=anthemP2(1:5:length(anthemP2));
    samp_anthemP2(:,:,i)=anthemP2;
    
    % good charlotte
    theAnthem=audioread('GoodCharlotteTheAnthem.wav',sample);
    theAnthem=theAnthem(:,1); theAnthem=theAnthem(1:5:length(theAnthem));
    samp_theAnthem(:,:,i)=theAnthem;
    richFamous=audioread('GoodCharlotteRichFamous.wav',sample);
    richFamous=richFamous(:,1); richFamous=richFamous(1:5:length(richFamous));
    samp_richFamous(:,:,i)=richFamous;
    littleThings=audioread('GoodCharlotteLittleThings.wav',sample);
    littleThings=littleThings(:,1); littleThings=littleThings(1:5:length(littleThings));
    samp_littleThings(:,:,i)=littleThings;
    
    % sum 41
    fatLip=audioread('Sum41FatLip.wav',sample);
    fatLip=fatLip(:,1); fatLip=fatLip(1:5:length(fatLip));
    samp_fatLip(:,:,i)=fatLip;
    inDeep=audioread('Sum41InDeep.wav',sample);
    inDeep=inDeep(:,1); inDeep=inDeep(1:5:length(inDeep));
    samp_inDeep(:,:,i)=inDeep;
    hellSong=audioread('Sum41HellSong.wav',sample);
    hellSong=hellSong(:,1); hellSong=hellSong(1:5:length(hellSong));
    samp_hellSong(:,:,i)=hellSong;
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
    num=idx(i);
    mult1=(5*(num-1)+1); mult2=(5*num)+1;
    sample=[(mult1*Fs) (mult2*Fs)];
    
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
test_spec_test1=test_spec_test1-mean(test_spec_test1);
%svd 
[u2,s2,v2]=svd(test_spec_test1,'econ');

% ut=u';
% test_proj=ut*test_spec_test1;

%% classify 
group=ones(48,1); % blink
group(49:96)=2; % eminem
group(97:144)=3; % johnny
%%
train1=v(1:30,:);
test1=v(31:36,:);
train2=v(37:54,:);
test2=v(55:60,:);
train3=v(61:90,:);
test3=v(91:96,:);
train4=v(97:114,:);
test4=v(115:120,:);
train5=v(121:150,:);
test5=v(151:156,:);
train6=v(157:174,:);
test6=v(175:180,:);

%%

trainData=[train1; train2; train3; train4; train5; train6];
testData=[test1; test2; test3; test4; test5; test6];

%%
rank=10;
%test1Class=classify(test_proj(1:rank,:)',v(:,1:rank),group); % use first 100
%plot(test1Class)
test1Class2=classify(testData(:,1:rank),trainData(:,1:rank),group); % use first 100
% rows to be samples 
% 15 test rows to classify det by first rank sing vals
% v - each row is one training song def by the sing vals 
% w each row of your training data, give it a label
figure(10)
plot(test1Class2),xlabel('Song Clip'),ylabel('Classification'), xticks([0 12 24 36])
title('Test 1 Rank 10 Classification')
% sing val plots for both
% eigenfaces of both 
% reconstruction with diff rank approx 
error_vec=[];
for i=1:length(test1Class2)
    val=test1Class2(i);
    if i<13
        error=abs(1-val);
    elseif i<25
        error=abs(2-val);
    else
        error=abs(3-val);
    end
    error_vec=[error_vec error];
end
     
%%
sing_vals=diag(s);

figure(1) 
plot(1:length(sing_vals),sing_vals,'r.-','MarkerSize',20)
title('Singular Values (Standard)')