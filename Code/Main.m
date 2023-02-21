
%% Project
%% organiziting the data
% Heart rate from seconds to minuets:
HeartData = readtable('heartrate_seconds_merged.csv');
Id = unique(HeartData.Id);
Id_ind = zeros(length(Id),2);
for i=1:length(Id)
    Id_ind(i,1) = find(HeartData.Id == Id(i),1,'first');
    Id_ind(i,2)=  find(HeartData.Id == Id(i),1,'last');
end
HeartMinuets = HeartData.Time.Minute; %minute of each heart beat
diff_min = find(diff(HeartMinuets)==1); diff_min=[0 diff_min']; %indexes that indicates at which index a minute changes
BPM = zeros(length(diff_min),1); Id_BPM = zeros(length(diff_min),1);
Date_BPM = NaT(length(diff_min),1);

for i=1:length(diff_min)-1
    BPM(i) = round(mean(HeartData.Value(diff_min(i)+1:diff_min(i+1))));
    Date_BPM(i)=HeartData.Time(diff_min(i)+1);
    Date_BPM(i).Second = 0;
    Id_BPM(i)=HeartData.Id(diff_min(i)+1);
end
%calories and steps per minute:
tic
calories=readtable('minuteCaloriesNarrow_merged.csv');
steps=readtable('minuteStepsNarrow_merged.csv');

calories_final = []; steps_final=[]; 
count1=0; count2=0; 
for i=1:length(Id)
    ind0=find(Id_BPM==Id(i));
    
    ind1=find(calories.Id==Id(i)); 
    calories_cut=calories.Calories(ind1);
    Time_calories = NaT(length(ind1),1);
    Time_calories = calories.ActivityMinute(ind1);
    
    ind2=find(steps.Id==Id(i)); 
    steps_cut=steps.Steps(ind2);
    Time_steps = NaT(length(ind2),1);
    Time_steps = steps.ActivityMinute(ind2);
    
    for j=1:length(ind0)
        a1=find(Time_calories==Date_BPM(ind0(j)));
        calories_final= [calories_final; calories_cut(a1)];
        if length(a1)==0
            calories_final= [calories_final; mean(calories_final)];
            count1 = count1+1;
        end
        
        a2=find(Time_steps==Date_BPM(ind0(j)));
        steps_final= [steps_final; steps_cut(a2)];
        if length(a2)==0
            steps_final= [steps_final; mean(steps_final)];
            count2 = count2+1;
        end
    end
end
toc

writetable(T,'Data.xlsx')

% intesity data
HourIntes = readtable('hourlyIntensities_merged.csv');
HourBPM = Date_BPM;
HourBPM.Minute = 0;

intensity_final = [];  count=0;
for i=1:length(Id)
    ind0=find(Id_BPM==Id(i));
    
    ind1=find(HourIntes.Id==Id(i)); 
    HourIntes_cut=HourIntes.AverageIntensity(ind1);
    Time_HourIntes = NaT(length(ind1),1);
    Time_HourIntes = HourIntes.ActivityHour(ind1);
    
    for j=1:length(ind0)
        a=find(Time_HourIntes==HourBPM(ind0(j)));
        intensity_final= [intensity_final; HourIntes_cut(a)];
        if length(a)==0
            intensity_final= [intensity_final; mean(HourIntes_cut)];
            count = count+1;
        end
    end 
end

% save:
Id_BPM=Id_BPM(1:length(intensity_final));
BPM=BPM(1:length(intensity_final));
Date_BPM=Date_BPM(1:length(intensity_final));

T=table(Id_BPM,Date_BPM,BPM,calories_final,steps_final,intensity_final);
writetable(T,'order_data.xlsx')

% splitting data to test data and learning/validation data:
data = readtable('order_data.xlsx');
X = [data.calories_final data.steps_final data.intensity_final];
y = data.BPM;
random_ind = randperm(length(y),65000); %to split data randomly
X_test = X(random_ind,:);
X_learn = X;
X_learn(random_ind,:)=[];
y_test = y(random_ind,:);
y_learn = y;
y_learn(random_ind,:)=[];

T=table(X_learn,y_learn);
writetable(T,'learn_data.xlsx')

T=table(X_test,y_test);
writetable(T,'test_data.xlsx')

%% download learn and test data:
learn_data = readtable('learn_data.xlsx');
X_learn = [learn_data.X_learn_1 learn_data.X_learn_2 learn_data.X_learn_3];
y_learn= learn_data.y_learn;

test_data = readtable('test_data.xlsx');
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
Succes_rate_2bpm = 1/length(y_test)*sum(abs(y_test-yhat)<=2)*100 % 14.1% for error of 2 bpm
Succes_rate_5bpm = 1/length(y_test)*sum(abs(y_test-yhat)<=5)*100 % 35
Succes_rate_err_bpm = 1/length(y_test)*sum(abs(y_test-yhat)<=error)*100 % 57.42 
%visualization of model
figure; subplot(2,1,1); scatter3(X_test(:,1), X_test(:,2), X_test(:,3),y_test,y_test)
c = colorbar; c.Label.String = 'BPM'; c.Limits = [40 180];
xlabel('calories'); ylabel('steps'); zlabel('intensities'); title('test BPM')
subplot(2,1,2); scatter3(X_test(:,1), X_test(:,2), X_test(:,3),yhat,yhat)
c = colorbar; c.Label.String = 'BPM'; c.Limits = [40 180];
xlabel('calories'); ylabel('steps'); zlabel('intensities'); title('predicted BPM')

%% Lasso
%Linear regression LASSO
lambda=[0.001,0.0001,0.000001,0.0000001];
J_Lasso=cell(length(lambda),1);
theta_Lasso=cell(length(lambda),1);
for i=1:length(lambda)
    [theta_Lasso{i},J_Lasso{i},~] = LinearRegLasso(X_learn,y_learn,10^5,0.001,lambda(i));
end

% results:
for i=1:length(lambda)
J(i)=J_Lasso{i}(end,1);
yhat = [ones(length(X_test),1) X_test]*theta_Lasso{i}'; %estimated BPM
error(i) = mean_error(y_test,yhat); %mean error
Succes_rate_2bpm(i) = 1/length(y_test)*sum(abs(y_test-yhat)<=2)*100; 
Succes_rate_5bpm(i) = 1/length(y_test)*sum(abs(y_test-yhat)<=5)*100;
Succes_rate_err_bpm(i) = 1/length(y_test)*sum(abs(y_test-yhat)<=error(i))*100;
end

%visualization of linear regression J   
figure; plot(J,lambda,'LineWidth',4); xlabel('Lambda');ylabel('J - cost function'); title('cost function as function of lambda');


%% Ridge
%Linear regression Ridge
tic
lambda=[0.001,0.0001,0.000001,0.0000001];
theta_ridge=cell(length(lambda),1);
J_ridge=cell(length(lambda),1);
for i=1:length(lambda)
    [theta_ridge{i},J_ridge{i},~] = LinearRegRidge(X_learn,y_learn,10^4,0.001,lambda(i));
end
toc

% results:
for i=1:length(lambda)
J(i)=J_ridge{i}(end,1);
yhat = [ones(length(X_test),1) X_test]*theta_ridge{i}'; %estimated BPM
error(i) = mean_error(y_test,yhat); %mean error
Succes_rate_2bpm(i) = 1/length(y_test)*sum(abs(y_test-yhat)<=2)*100; 
Succes_rate_5bpm(i) = 1/length(y_test)*sum(abs(y_test-yhat)<=5)*100;
Succes_rate_err_bpm(i) = 1/length(y_test)*sum(abs(y_test-yhat)<=error(i))*100;
end

%visualization of linear regression J   
figure; plot(J,lambda,'LineWidth',4); xlabel('Lambda');ylabel('J - cost function'); title('cost function as function of lambda');


%% k means
%organizing data
clear
data2 = readtable('order_data.xlsx');
X = [data2.BPM data2.calories_final data2.steps_final];
Id_BPM = data2.Id_BPM; Id = unique(data2.Id_BPM); 
MET = readtable('minuteMETsNarrow_merged.csv');
MET_final = [];
count = 0;
for i=1:length(Id)
    ind0=find(Id_BPM==Id(i));
    ind1=find(MET.Id==Id(i)); 
    MET_cut=MET.METs(ind1);
    Time_MET = NaT(length(ind1),1);
    Time_MET = MET.ActivityMinute(ind1);
    
    for j=1:length(ind0)
        a=find(Time_MET==data2.Date_BPM(ind0(j)));
        MET_final= [MET_final; MET_cut(a)];
        if length(a)==0
            MET_final= [MET_final; mean(MET_cut)];
            count = count+1;
        end
    end 
end
%categorization
MET_final2 = MET_final;
MET_final2(MET_final<=44)=1;
MET_final2(MET_final>44&MET_final<=78)=2;
MET_final2(MET_final>78&MET_final<=112)=3;
MET_final2(MET_final>112)=4;

%plotting data vs MET
figure; scatter3(X(:,1), X(:,2), X(:,3),MET_final2,MET_final2)
xlabel('BPM'); ylabel('calories'); zlabel('steps');
title('Intensity');
%K-means
colors = rand(4,3); %random RGB triplets
for p=1:3
[centro,,,~] = Kmeans_3D(X,4,0,1000);
for i=1:size(X,1)
    [~,ind(i)] = min(sum((centro-[data2.BPM(i) data2.calories_final(i) data2.steps_final(i)]).^2,2));  %index of closest centroid to a data point
end
    figure;
for j=1:4
    scatter3(data2.BPM(ind==j),data2.calories_final(ind==j),data2.steps_final(ind==j),[],colors(j,:))
    hold on; scatter3(centro(j,1),centro(j,2),centro(j,3),[],colors(j,:),'+');
    hold on;
end
    xlabel('BPM'); ylabel('calories');zlabel('steps'), title('Clasification');
end

Class_data = [X MET_final2];


%% download learn and test data:
learn_data = readtable('learn_data_calssification.xlsx');
X_learn = [learn_data.BPM learn_data.Calories learn_data.Steps];
y_learn= learn_data.Intesity;

Learn=[y_learn,X_learn];

test_data = readtable('test_data_withintens.xlsx');
X_test =table(tX_test_1,X_test_2,X_test_1);
y_test= test_data.Intesity;


yhat=Gaus.predictFcn(X_test);
length(find(y_test-yhat==0))/length(yhat)*100



