clear all; close all; clc; 

%%
load('cam1_3.mat'); load('cam2_3.mat'); load('cam3_3.mat');

% load videos from each camera and save number of frames 
vid1=vidFrames1_3; numFrames1=size(vid1,4); 
vid2=vidFrames2_3; numFrames2=size(vid2,4);
vid3=vidFrames3_3; numFrames3=size(vid3,4);

% prepare frames for processing 
for k=1:numFrames1
    mov1(k).cdata=vid1(:,:,:,k);
    mov1(k).colormap=[];
end
for k=1:numFrames2
    mov2(k).cdata=vid2(:,:,:,k);
    mov2(k).colormap=[];
end
for k=1:numFrames3
    mov3(k).cdata=vid3(:,:,:,k);
    mov3(k).colormap=[];
end 

%% cam1
cRow1=286; cCol1=321; % beginning guess of coordinates of light/eraser
rowTotal=[]; colTotal=[];
for j=1:numFrames1 % iterate through the frames
    f=frame2im(mov1(j)); % convert each frame in the video to a photo
    window=f(cRow1-10:cRow1+10,cCol1-10:cCol1+10,:); % form window around guess
    S=sum(window,3); % sum the rgb components 
    if max(S(:))<655 % if cannot find white light, look for pink (eraser)
        r=window(:,:,1); % pull all red values in window
        g=window(:,:,2)<200; % where green values are less than 200 (logical)
        b=window(:,:,3)<200; % where blue values are less than 200 (logical)
        bgsum=b+g; % sum blue and green components (logical, so 0,1,2)
        ind=bgsum==2; % where both blue and green are less than 200 
        [~,idx]=max(r(ind)); % find max red where blue and green are low
        [row,col]=ind2sub(size(r),idx); % store row/column 
    else
        [~,idx]=max(S(:)); % find the max rbg (white light)
        [row,col]=ind2sub(size(S),idx); % store the row and column the max appeared 
    end
    row=(cRow1-10)+row; col=(cCol1-10)+col; % put back into original frame pixel space 
    cRow1=row; cCol1=col; % set new center guess of flashlight/eraser
    rowTotal=[rowTotal row]; colTotal=[colTotal col]; % add to a total row/column vec
end

Xa=colTotal; Ya=rowTotal;

%% cam2 - same process as cam1
cRow2=292; cCol2=238; % beginning guess 
rowTotal=[]; colTotal=[];
for j=1:numFrames2 
    f=frame2im(mov2(j));
    window=f(cRow2-15:cRow2+15,cCol2-15:cCol2+15,:);
    S=sum(window,3);  
    if max(S(:))<655
        r=window(:,:,1);
        g=window(:,:,2)<200;
        b=window(:,:,3)<200;
        bgsum=b+g;
        ind=bgsum==2;
        [~,idx]=max(r(ind));
        [row,col]=ind2sub(size(r),idx);
    else
        [~,idx]=max(S(:)); 
        [row,col]=ind2sub(size(S),idx);  
    end
    row=(cRow2-15)+row; col=(cCol2-15)+col; 
    cRow2=row; cCol2=col;
    rowTotal=[rowTotal row]; colTotal=[colTotal col]; 
end

Xb=colTotal; Yb=rowTotal;

%% cam3 - same process as cam1,cam2
cRow3=246; cCol3=348; % beginning guess 
rowTotal=[]; colTotal=[];
for j=1:numFrames3 
    f=frame2im(mov3(j)); 
    window=f(cRow3-15:cRow3+15,cCol3-15:cCol3+15,:); 
    S=sum(window,3); 
    if max(S(:))<655
        r=window(:,:,1);
        g=window(:,:,2)<200;
        b=window(:,:,3)<200;
        bgsum=b+g;
        ind=bgsum==2;
        [~,idx]=max(r(ind));
        [row,col]=ind2sub(size(r),idx);
    else
        [~,idx]=max(S(:)); 
        [row,col]=ind2sub(size(S),idx); 
    end
    row=(cRow3-15)+row; col=(cCol3-15)+col; 
    cRow3=row; cCol3=col;
    rowTotal=[rowTotal row]; colTotal=[colTotal col]; 
end

Xc=rowTotal; Yc=colTotal;

%% align vector peaks and truncate so they are the same length
Xa=Xa(10:235); Ya=Ya(10:235);
Xb=Xb(1:226); Yb=Yb(1:226);
Xc=Xc(4:229); Yc=Yc(4:229); 

%plot(1:226,Ya,1:226,Yb,1:226,Yc)
%legend('Ya','Yb','Yc','Location','northeast')
%xticks([0 20 35 50])

%% subtract column means and SVD

% subtract mean 
Xa=Xa-mean(Xa); Ya=Ya-mean(Ya);
Xb=Xb-mean(Xb); Yb=Yb-mean(Yb);
Xc=Xc-mean(Xc); Yc=Yc-mean(Yc);

% vector of all with subtracted column means 
X=[Xa;Ya;Xb;Yb;Xc;Yc]'; % X transpose so that it is 6x226
[u,s,v]=svd(X,0); % svd
sing_vals=diag(s); % pull out singular values 

% plot the singular values and dominant modes found from SVD 
figure(1)
subplot(3,2,1) 
plot(1:length(sing_vals),sing_vals,'k.','MarkerSize',20)
title('Singular Values (Standard)')
subplot(3,2,2) 
plot(1:length(sing_vals),sing_vals,'k.','MarkerSize',20)
set(gca, 'YScale', 'log')
title('Singular Values (Log)')

subplot(3,1,2)
plot(1:6,v(:,1),'.-',1:6,v(:,2),'.-')
legend('Mode 1', 'Mode 2', 'Location', 'northeast')
xticks([1 2 3 4 5 6]), title('Linear POD Modes')

subplot(3,1,3)
plot(1:226,u(:,1),1:226,u(:,2))
legend('Mode 1', 'Mode 2', 'Location', 'northeast'),ylim([-0.2 0.2]),xlim([0 226])
ylabel('Displacement'), xlabel('Video Frame'), title('Time Evolution Behavior')