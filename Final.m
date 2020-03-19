clear all
files=gunzip('*.gz');
trainIm=loadMNISTImages('train-images-idx3-ubyte');
trainLab=loadMNISTLabels('train-labels-idx1-ubyte');
%%
trainIm1=trainIm-mean(trainIm);
[U,S,V]=svd(trainIm1,'econ');

%%
testIm=loadMNISTImages('t10k-images-idx3-ubyte');
testLab=loadMNISTLabels('t10k-labels-idx1-ubyte');
%%
rankVals=[1;5;10;15;25;50;75;100;250];
testIm2=testIm-mean(testIm);
testProjected=U'*testIm2;
for i =1:9
    test1Class=classify(testProjected(1:rankVals(i),:)',V(:,1:rankVals(i)),trainLab);
    subplot(3,3,i)
    hist(test1Class)
    percentCor(i)=sum(test1Class-testLab==0)/100;
    title(['Rank ',num2str(rankVals(i)),' classification - ',num2str(percentCor(i)),'% correct'])
end
%%
figure
for i=1:9
    subplot(3,3,i)
    uface=reshape(U(:,i),28,28);
    pcolor(flipdim(uface,1)); colormap('gray'); shading('flat');
end
sgtitle('First 9 Eigen-numbers')
%%
count=[1 2 3 1 2 3 1 2 3];
numCount=[5 5 5 11 11 11 50 50 50];
rankVals=[10;50;125];
for i=1:9
    counter=count(i);
    subplot(3,3,i)
    rank=rankVals(counter);
    num=numCount(i)*150;
    recon=U(:,1:rank)*S(1:rank,1:rank)*V(:,1:rank)';
    recon1=recon(:,num);
    im1=reshape(recon1,28,28);
    pcolor(flipdim(im1,1)); colormap('gray'); shading('flat');
    title('Rank '+string(rankVals(counter))+' Reconstruction');
end
sgtitle('Reconstruction of Images')


%% Other classification tests
%testProjected(1:rankVals(i),:)',V(:,1:rankVals(i)),trainLab
rankVals=[5;5;10;10;25;25;50;50];
Neighbor=[3 5 3 5 3 5 3 5];
testIm2=testIm-mean(testIm);
testProjected=U'*testIm2;
for i =1:8
    rank=rankVals(i);
    NN=Neighbor(i);
    trainTbl=array2table(V(:,1:rank));
    testTbl=array2table(testProjected(1:rank,:)');
    mod=fitcknn(trainTbl,trainLab,'NumNeighbors',NN);
    knnPrediction=predict(mod,testTbl);
    subplot(4,2,i)
    hist(knnPrediction)
    percentCor(i)=sum(knnPrediction-testLab==0)/100;
    title(['Rank ',num2str(rankVals(i)),' knn classification (k=', num2str(NN),') - ',num2str(percentCor(i)),'% correct'])
    clear mod
end

%% train knn model
%mod=fitcknn(trainTbl,trainLab,'NumNeighbors',3);
%% predict with knn model
%knnPrediction=predict(mod,testTbl);
%% summary
%percentCorKnn=sum(knnPrediction-testLab==0)/100;
%hist(knnPrediction);

