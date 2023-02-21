tic
calories=readtable('minuteCaloriesNarrow_merged.csv');
steps=readtable('minuteStepsNarrow_merged.csv');
intensity=readtable('minuteIntensitiesNarrow_merged.csv');

calories_final = []; steps_final=[]; intensity_final=[]; 
count1=0; count2=0; count3=0; 
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
    
    ind3=find(intensity.Id==Id(i)); 
   intensity_cut=intensity.Intensity(ind3);
    Time_intensity = NaT(length(ind3),1);
    Time_intensity = intensity.ActivityMinute(ind3);
    
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
        
        a3=find(Time_intensity==Date_BPM(ind0(j)));
       intensity_final= [intensity_final; intensity_cut(a3)];
        if length(a3)==0
            intensity_final= [intensity_final; floor(mean(intensity_final))];
            count3 = count3+1;
        end
    end
end
toc
unique(intensity_final)
intensity_final=intensity_final+1;
T=table(intensity_final,BPM,steps_final,calories_final);
writetable(T,'Data_withintens.xlsx')


X = [BPM,calories_final steps_final];
y = intensity_final;
random_ind = randperm(length(y),65000); %to split data randomly
X_test = X(random_ind,:);
X_learn = X;
X_learn(random_ind,:)=[];
y_test = y(random_ind,:);
y_learn = y;
y_learn(random_ind,:)=[];

T=table(X_learn,y_learn);
writetable(T,'learn_data_withintens.xlsx')

T=table(X_test,y_test);
writetable(T,'test_data_withintens.xlsx')

%%
learn_data = readtable('learn_data_withintens.xlsx');
X_learn = [learn_data.X_learn_1 learn_data.X_learn_2 learn_data.X_learn_3];
y_learn= learn_data.y_learn;

Learn=[y_learn,X_learn];

test_data = readtable('test_data_withintens.xlsx');
X_test = [test_data.X_test_1 test_data.X_test_2 test_data.X_test_3];
y_test= test_data.y_test;