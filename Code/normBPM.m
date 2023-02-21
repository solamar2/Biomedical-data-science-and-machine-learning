%% trying mean BPM
Id_ind = zeros(length(Id),2);
for i=1:length(Id)
    Id_ind(i,1) = find(Id_BPM == Id(i),1,'first');
    Id_ind(i,2)=  find(Id_BPM == Id(i),1,'last');
end
BPM=data2.BPM; count=1;
for i=1:length(Id_ind)
    BPM_m=mean(BPM(Id_ind(i,1):Id_ind(i,2)));
    BPM_norm(count:count+length(BPM(Id_ind(i,1):Id_ind(i,2)))-1)=BPM(Id_ind(i,1):Id_ind(i,2))-BPM_m;
    count=count+length(BPM(Id_ind(i,1):Id_ind(i,2)));
end

y=BPM_norm';

%%
X = [data2.calories_final data2.steps_final data2.intensity_final];
random_ind = randperm(length(y),65000); %to split data randomly
X_test = X(random_ind,:);
X_learn = X;
X_learn(random_ind,:)=[];
y_test = y(random_ind,:);
y_learn = y;
y_learn(random_ind,:)=[];

T=table(X_learn,y_learn);
writetable(T,'learn_data_normBPM.xlsx')

T=table(X_test,y_test);
writetable(T,'test_data_normBPM.xlsx')

%% download learn and test data:
learn_data = readtable('learn_data_normBPM.xlsx');
X_learn = [learn_data.X_learn_1 learn_data.X_learn_2 learn_data.X_learn_3];
y_learn= learn_data.y_learn;

test_data = readtable('test_data_normBPM.xlsx');
X_test = [test_data.X_test_1 test_data.X_test_2 test_data.X_test_3];
y_test= test_data.y_test;

%% Linear regression
tic
[theta,J,theta_mat] = LinearRegProject(X_learn,y_learn,10^5,0.001);
toc

%visualization of linear regression J   
figure;subplot(2,2,1); scatter3(theta_mat(:,1),1:length(J),J)
xlabel('\theta_1'); ylabel('iteration'); zlabel('J')
subplot(2,2,2); scatter3(theta_mat(:,2),1:length(J),J)
xlabel('\theta_2'); ylabel('iteration'); zlabel('J')
subplot(2,2,3); scatter3(theta_mat(:,3),1:length(J),J)
xlabel('\theta_3'); ylabel('iteration'); zlabel('J')
subplot(2,2,4); scatter3(theta_mat(:,4),1:length(J),J)
xlabel('\theta_4'); ylabel('iteration'); zlabel('J')
sgtitle('Linear Regression J as function of \thetas, alpha = 0.001, p=10^5') 

% results:
yhat = [ones(length(X_test),1) X_test]*theta'; %estimated BPM
error = mean_error(y_test,yhat); %mean error
Succes_rate_2bpm = 1/length(y_test)*sum(abs(y_test-yhat)<=2)*100 
Succes_rate_5bpm = 1/length(y_test)*sum(abs(y_test-yhat)<=5)*100
Succes_rate_err_bpm = 1/length(y_test)*sum(abs(y_test-yhat)<=error)*100 

BPM1=mean(data2.BPM(Id_ind(1,1):Id_ind(1,2)));
yhat_BPM=BPM1+yhat;
ytest_BPM=BPM1+y_test;

CI=[ytest_BPM,yhat_BPM];
CI_wanted=[ytest_BPM+5,ytest_BPM-5];
figure
scatter(1:50,ytest_BPM(1:50),'filled')
hold on
scatter(1:50,yhat_BPM(1:50),'filled')
for i=1:50
plot([i,i],CI_wanted(i,:),'color','k')
end
xlabel 'num of subject'; ylabel 'BPM'; legend('true BPM','estimated BPM');

yhat = [ones(length(X_test),1) X_test]*theta'; %estimated BPM

y_test=ytest_BPM;
yhat=yhat_BPM;
MeanDiff = mean(y_test) - mean(yhat)
Vary_test = var(y_test);
N1 = length(y_test);
Varyhat = var(yhat);
N2 = length(yhat);
SEComb = sqrt(Vary_test/N1 + Varyhat/N2);
df = N1 + N2 - 2;
tstat = MeanDiff/SEComb;
P = 1 - tcdf(tstat , df); % 0.9519

std1 = std(y_test); std2 = std(yhat);
mean1 = mean(y_test); mean2 = mean(yhat);
numRep=200;
HWGrRep = normrnd(mean1, std1, N1, numRep);
noHWGrRep = normrnd(mean2, std2, N2, numRep);
MeanDiffRep = mean(HWGrRep) - mean(noHWGrRep);
VarHWGrRep = var(HWGrRep);
VarnoHWGrRep = var(noHWGrRep);
SECombRep = sqrt(VarHWGrRep/N1 + VarnoHWGrRep/N2);
tstatRep = MeanDiffRep./SECombRep;
pRep = 1 - tcdf(tstatRep, df);
powerTest = sum(pRep<0.05)/numRep*100


%% model for each person
data = readtable('order_data.xlsx');

IDS=unique(data.Id_BPM)
for i=1:14
    ind=find(data.Id_BPM==IDS(i));
    BPM_m=mean(data.BPM(ind));
    BPM_norm=data.BPM(ind)-BPM_m;
    x=[data.calories_final(ind),data.steps_final(ind),data.intensity_final(ind)];
    y=BPM_norm;
    N=floor(length(y)*0.8);
    random_ind = randperm(length(y),N); %to split data randomly 
    X_test = x(random_ind,:);
    X_learn = x;
    X_learn(random_ind,:)=[];
    y_test = y(random_ind,:);
    y_learn = y;
    y_learn(random_ind,:)=[];
    
    learn_data = table(X_learn(:,1),X_learn(:,2),X_learn(:,3), y_learn);
    
mdl = fitrsvm(learn_data,'y_learn','KernelFunction','gaussian','KernelScale',2.2,'Standardize',true);


yhat = predict(mdl,X_test);

error_tree(i) = mean(y_test-yhat);
Succes_rate_2bpm(i) = 1/length(y_test)*sum(abs(y_test-yhat)<=2)*100 
Succes_rate_5bpm(i) = 1/length(y_test)*sum(abs(y_test-yhat)<=5)*100

MeanDiff = mean(y_test) - mean(yhat)
Vary_test = var(y_test);
N1 = length(y_test);
Varyhat = var(yhat);
N2 = length(yhat);
SEComb = sqrt(Vary_test/N1 + Varyhat/N2);
df = N1 + N2 - 2;
tstat = MeanDiff/SEComb;
P(i) = 1 - tcdf(tstat , df);
end
%% for subject 7:
y_test=y_test+BPM_m;
yhat=yhat+BPM_m;

CI=[y_test,yhat];
CI_wanted=[y_test+5,y_test-5];

figure
scatter(1:50,y_test(1:50),'filled')
hold on
scatter(1:50,yhat(1:50),'filled')
for i=1:50
plot([i,i],CI_wanted(i,:),'color','k')
end
xlabel 'num of meas'; ylabel 'BPM'; legend('true BPM','estimated BPM');
