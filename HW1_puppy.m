clear all; close all; clc; 
load Testdata

%% Define Domain 

L=15; % define computational spatial domain 
n=64; % Fourier/frequency modes 2^n
x2=linspace(-L,L,n+1); % define spatial discretization
x=x2(1:n); y=x; z=x; % consider first n points: periodic 

k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; % wave #s of FFT, rescaled & shifted
ks=fftshift(k); % undo the FT shift, bring back to our domain

[X,Y,Z]=meshgrid(x,y,z); % measurement dimension
[Kx,Ky,Kz]=meshgrid(ks,ks,ks); % meshgrid frequency (wave #) domain

%% Average Over Data 

Uave=zeros(n,n,n); % 3D matrix of zeros

for j=1:20 
    Un(:,:,:)=reshape(Undata(j,:),n,n,n);
    UnT=fftn(Un); % Fourier transform
    Uave=Uave+UnT; % add multi-dim ft (fftn) of current data to avg
end

Uave=fftshift(Uave)/20;

% extract max frequency signature
[maxavg,i]=max(abs(Uave(:))); 
[p1,p2,p3]=ind2sub(size(Uave),i); % indexes

ksx=Kx(p1,p2,p3); % max k values
ksy=Ky(p1,p2,p3); 
ksz=Kz(p1,p2,p3); 

close all
figure(1) % plot in frequency domain 
isosurface(Kx,Ky,Kz,abs(Uave)/max(abs(Uave(:))),0.6)
axis([-6 6 -6 6 -6 6]), grid on;
xlabel('Kx'); ylabel('Ky'); zlabel('Kz');

%% Apply 3D Gaussian Filter

% filter centered around max k values ksx, ksy, ksz
gfilter=exp(-0.5*((Kx-ksx).^2 + (Ky-ksy).^2 + (Kz-ksz).^2));

close all
figure(2) % plot the Gaussian filter over frequency domain 
isosurface(Kx,Ky,Kz,abs(gfilter),0.6)
axis([-6 6 -6 6 -6 6]), grid on;
xlabel('Kx'); ylabel('Ky'); zlabel('Kz'); 

xtr=[]; % initialize trajectory vectors
ytr=[]; 
ztr=[];  

figure(3) % plot trajectory with filter 
for j=1:20 
    Un(:,:,:)=reshape(Undata(j,:,:),n,n,n);
    Unt=fftn(Un); % fft of Un
    Unts=fftshift(Unt); % shift ft
    Unf=gfilter.*(Unts); % apply the filter to shifted ft
    Unfs=ifftshift(Unf); % unshift
    Utn=ifftn(Unfs); % inverse ft 
    
    isosurface(X,Y,Z,abs(Utn)/max(abs(Utn(:))),0.6)
    axis([-20 20 -20 20 -20 20]), grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');

    [maxU,i]=max(abs(Utn(:))); % extract max spatial values
    [p12,p22,p32]=ind2sub(size(Utn),i);
    
    xt=X(p12,p22,p32); % values of max in spatial domain
    yt=Y(p12,p22,p32); 
    zt=Z(p12,p22,p32);
    
    xtr=[xtr xt]; % append to trajectory vectors
    ytr=[ytr yt]; 
    ztr=[ztr zt];
    
end

plot3(xtr(:),ytr(:),ztr(:)), grid on % plot trajectories
axis([-15 15 -15 15 -15 15]),
xlabel('X'); ylabel('Y'); zlabel('Z'); 

finalpos=[xtr(20) ytr(20) ztr(20)] % extract final marble position
