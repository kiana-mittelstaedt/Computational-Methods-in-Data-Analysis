clear all; close all; clc
%% Cropped Images 
crop=unzip('yalefaces_cropped.zip'); % unzip photos
crop(contains(string(crop),'MACOSX'))=[]; % remove mac os images

%%
% try-catch commands found online to help go through folders 
for i=3:length(crop)
    try
        cropim_temp=imread(string(crop(i))); % read each image
        crop_reshape=reshape(cropim_temp,192*168,1); % reshape into column vector 
        crop_im(:,i-2)=(crop_reshape); % store all images as column vectors into a matrix
    catch
    end
end
crop_im=double(crop_im); % reshape to double
%%
crop_im=crop_im-mean(crop_im); % remove mean column-wise 
[uc,sc,vc]=svd(crop_im,'econ'); % svd - cropped images 
sing_vals=diag(sc); % pull out the singular values 

% plot the singular values 
figure(1) 
subplot(2,1,1), plot(1:length(sing_vals),sing_vals,'k.-','MarkerSize',20)
title('Singular Values (Standard)'),xlabel('Mode Number'),ylabel('Singular Value')
subplot(2,1,2), plot(1:length(sing_vals),sing_vals,'k.-','MarkerSize',20),xlim([0 50]);
title('First 50 Singular Values'),xlabel('Mode Number'),ylabel('Singular Value')

%% plot U - eigenfaces
figure(3)
for j=1:12
    subplot(3,4,j)
    eface=reshape(uc(:,j),[192,168]);
    pcolor(eface); shading flat; colormap gray; axis ij;
    title(['PC',num2str(j)])
end

%% reconstruct
rank=200;
im_new=uc(:,1:rank)*sc(1:rank,1:rank)*vc(:,1:rank)';

%% uncropped images 
uncrop=untar('yalefaces_uncropped.tar');

%% untar and store each image as a column vector 
for i=3:length(uncrop)-1
    uncropim_temp=importdata(string(uncrop(i)));
    uncropim_dat=uncropim_temp.cdata;
    uncropim_reshape=reshape(uncropim_dat,243*320,1);
    uncrop_im(:,i-2)=uncropim_reshape;
end
uncrop_im=double(uncrop_im);

%%
uncrop_im=uncrop_im-mean(uncrop_im); % remove mean
[uuc,suc,vuc]=svd(uncrop_im,'econ'); % svd 
sing_vals2=diag(suc);

figure(5) 
subplot(2,1,1), plot(1:length(sing_vals2),sing_vals2,'k.-','MarkerSize',20)
title('Singular Values (Standard)'),xlabel('Mode Number'),ylabel('Singular Value')
subplot(2,1,2), plot(1:length(sing_vals2),sing_vals2,'k.-','MarkerSize',20),xlim([0 25]);
title('First 25 Singular Values'),xlabel('Mode Number'),ylabel('Singular Value')

%% plot U
figure(7)
for j=1:6
    subplot(2,3,j)
    eface1=reshape(uuc(:,j),[243,320]);
    pcolor(eface1); shading flat; colormap gray; axis ij;
    title(['PC',num2str(j)])
end

%% reconstruct
rank=20;
im_new2=uuc(:,1:rank)*suc(1:rank,1:rank)*vuc(:,1:rank)';

