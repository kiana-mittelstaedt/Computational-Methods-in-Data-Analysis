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

energy1=sum(sing_vals(1:300))/sum(sing_vals);
energy2=sum(sing_vals(301:600))/sum(sing_vals);
energy3=sum(sing_vals(601:900))/sum(sing_vals);
energy4=sum(sing_vals(901:1200))/sum(sing_vals);
energy5=sum(sing_vals(1201:1500))/sum(sing_vals);
energy6=sum(sing_vals(1501:1800))/sum(sing_vals);
energy7=sum(sing_vals(1801:2100))/sum(sing_vals);
energy8=sum(sing_vals(2101:2400))/sum(sing_vals);

y=[energy1 energy2 energy3 energy4 energy5 energy6 energy7 energy8];
x=categorical({'0-300','301-600','601-900','901-1200','1201-1500','1501-1800','1801-2100','2101-2400'});
x=reordercats(x,{'0-300','301-600','601-900','901-1200','1201-1500','1501-1800','1801-2100','2101-2400'});  

figure(2)
bar(x,y), ylabel('Energy'),xlabel('Range of Singular Values'),title('Percentage Captured')

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
%% plot reconstruction
figure(4)
for i=1:12
    if i==1 
        recon=reshape(crop_im(:,6),[192,168]); 
    elseif i==2
        pic=uc(:,1:10)*sc(1:10,1:10)*vc(:,1:10)';
        recon=reshape(pic(:,6),[192,168]); 
    elseif i==3
        pic=uc(:,1:150)*sc(1:150,1:150)*vc(:,1:150)';
        recon=reshape(pic(:,6),[192,168]);
    elseif i==4
        pic=uc(:,1:300)*sc(1:300,1:300)*vc(:,1:300)';
        recon=reshape(pic(:,6),[192,168]);
    elseif i==5
        recon=reshape(crop_im(:,100),[192,168]); 
    elseif i==6
        pic=uc(:,1:10)*sc(1:10,1:10)*vc(:,1:10)';
        recon=reshape(pic(:,100),[192,168]); 
    elseif i==7
        pic=uc(:,1:150)*sc(1:150,1:150)*vc(:,1:150)';
        recon=reshape(pic(:,100),[192,168]); 
    elseif i==8
        pic=uc(:,1:300)*sc(1:300,1:300)*vc(:,1:300)';
        recon=reshape(pic(:,100),[192,168]); 
    elseif i==9
        recon=reshape(crop_im(:,350),[192,168]);
    elseif i==10
        pic=uc(:,1:10)*sc(1:10,1:10)*vc(:,1:10)';
        recon=reshape(pic(:,350),[192,168]); 
    elseif i==11
        pic=uc(:,1:150)*sc(1:150,1:150)*vc(:,1:150)';
        recon=reshape(pic(:,350),[192,168]); 
    else
        pic=uc(:,1:300)*sc(1:300,1:300)*vc(:,1:300)';
        recon=reshape(pic(:,350),[192,168]); 
    end
    subplot(3,4,i)
    pcolor(recon); shading flat; colormap gray; axis ij;
    if i==1 | i==5 | i==9
        title('Original')
    elseif i==2 | i==6 | i==10
        title('r=10')
    elseif i==3 | i==7 | i==11
        title('r=150')
    else
        title('r=300')
    end
end 

%% uncropped images 
uncrop=untar('yalefaces_uncropped.tar');

%% 
for i=3:length(uncrop)-1
    uncropim_temp=importdata(string(uncrop(i)));
    uncropim_dat=uncropim_temp.cdata;
    uncropim_reshape=reshape(uncropim_dat,243*320,1);
    uncrop_im(:,i-2)=uncropim_reshape;
end
uncrop_im=double(uncrop_im);

%%
uncrop_im=uncrop_im-mean(uncrop_im); % remove mean
% svd 
[uuc,suc,vuc]=svd(uncrop_im,'econ');
sing_vals2=diag(suc);

figure(5) 
subplot(2,1,1), plot(1:length(sing_vals2),sing_vals2,'k.-','MarkerSize',20)
title('Singular Values (Standard)'),xlabel('Mode Number'),ylabel('Singular Value')
subplot(2,1,2), plot(1:length(sing_vals2),sing_vals2,'k.-','MarkerSize',20),xlim([0 25]);
title('First 25 Singular Values'),xlabel('Mode Number'),ylabel('Singular Value')

energy12=sum(sing_vals2(1:40))/sum(sing_vals2);
energy22=sum(sing_vals2(41:80))/sum(sing_vals2);
energy32=sum(sing_vals2(81:120))/sum(sing_vals2);
energy42=sum(sing_vals2(121:160))/sum(sing_vals2);

y2=[energy12 energy22 energy32 energy42];
x2=categorical({'0-40','41-80','81-120','121-140'});
x2=reordercats(x2,{'0-40','41-80','81-120','121-140'});  

figure(6)
bar(x2,y2), ylabel('Energy'),xlabel('Range of Singular Values'),title('Percentage Captured')
%% plot U
figure(7)
for j=1:6
    subplot(2,3,j)
    eface1=reshape(uuc(:,j),[243,320]);
    pcolor(eface1); shading flat; colormap gray; axis ij;
    title(['PC',num2str(j)])
end

%% reconstruct
rank=21;

im_new2=uuc(:,1:rank)*suc(1:rank,1:rank)*vuc(:,1:rank)';

%% plot reconstruction
figure(8)
for i=1:12
    if i==1 
        recon=reshape(uncrop_im(:,10),[243,320]); 
    elseif i==2
        pic=uuc(:,1:5)*suc(1:5,1:5)*vuc(:,1:5)';
        recon=reshape(pic(:,10),[243,320]); 
    elseif i==3
         pic=uuc(:,1:30)*suc(1:30,1:30)*vuc(:,1:30)';
        recon=reshape(pic(:,10),[243,320]); 
    elseif i==4
         pic=uuc(:,1:100)*suc(1:100,1:100)*vuc(:,1:100)';
        recon=reshape(pic(:,10),[243,320]); 
    elseif i==5
        recon=reshape(uncrop_im(:,65),[243,320]); 
    elseif i==6
         pic=uuc(:,1:5)*suc(1:5,1:5)*vuc(:,1:5)';
        recon=reshape(pic(:,65),[243,320]); 
    elseif i==7
        pic=uuc(:,1:30)*suc(1:30,1:30)*vuc(:,1:30)';
        recon=reshape(pic(:,65),[243,320]);
    elseif i==8
        pic=uuc(:,1:100)*suc(1:100,1:100)*vuc(:,1:100)';
        recon=reshape(pic(:,65),[243,320]);
    elseif i==9
        recon=reshape(uncrop_im(:,120),[243,320]);
    elseif i==10
         pic=uuc(:,1:5)*suc(1:5,1:5)*vuc(:,1:5)';
        recon=reshape(pic(:,120),[243,320]);  
    elseif i==11
        pic=uuc(:,1:30)*suc(1:30,1:30)*vuc(:,1:30)';
        recon=reshape(pic(:,120),[243,320]);  
    else
        pic=uuc(:,1:100)*suc(1:100,1:100)*vuc(:,1:100)';
        recon=reshape(pic(:,120),[243,320]);  
    end
    subplot(3,4,i)
    pcolor(recon); shading flat; colormap gray; axis ij;
    if i==1 | i==5 | i==9
        title('Original')
    elseif i==2 | i==6 | i==10
        title('r=5')
    elseif i==3 | i==7 | i==11
        title('r=30')
    else
        title('r=100')
    end
end 
