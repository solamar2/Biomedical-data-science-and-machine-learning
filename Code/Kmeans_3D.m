function [centro,ind,converge,count,fig] = Kmeans_3D(data,K,plot_ans,max_ans)
%% This function runs a 3-D K-means algorithm
%% inputs:
% data- a data matrix which its 3 first columns will be used as features
% for the 3-D K-means
% K - # of groups we classify our data to
% plot_ans - if you want to plot the first 9 iterations of the algorithm assign plot = 1 
% max_ans - maximum number of iterations we want the algorithm to run
%% outputs:
% centro - the centroids recieved after convergence
% ind - the indexes relaying each data point to its closest centroid
% converge - # of iterations needed for convergence
% count - # of iterations before termination
% fig - an object of the figure plotted , empty if plot_ans ~= 1
%% important,read!! - if you choose plot_ans ~= 1 call the function without the fig variable or it will return an error
%%
colors = rand(K,3); %random RGB triplets
feat_1 = data(:,1);
feat_2 = data(:,2);
feat_3 = data(:,3);
m = length(feat_1);
if K>m
    error('K must be smaller then the size of the data sets');
end
rand_k = randperm(m,K);       %k random unique indexes from the features' indexes
centro = [feat_1(rand_k) feat_2(rand_k) feat_3(rand_k)];          %intial centroid coordinates
ind = zeros(1,m);     %intialization of index of closest centroid to a data point
count = 0; % counts the iterations
flag = 0;  %to alert convergence
if plot_ans == 1 %if we want to plot the group prediction for the first 9 iterations
    fig = figure;
end 
while count~=max_ans
for i=1:m
    [~,ind(i)] = min(sum((centro-[feat_1(i) feat_2(i) feat_3(i)]).^2,2));          %index of closest centroid to a data point
end
if plot_ans == 1 && count<9  %if we want to plot an iteration's group prediction
    subplot(3,3,count+1);
    for j=1:K
        scatter3(feat_1(ind==j),feat_2(ind==j),feat_3(ind==j),[],colors(j,:))
        hold on; scatter3(centro(j,1),centro(j,2),centro(j,3),[],colors(j,:),'+');
        hold on;
    end
    xlabel('feature 1'); ylabel('feature 2');zlabel('feature 3'), title(['iteration: ' num2str(count+1)]);
    hold on;
end
centro_temp = centro;
for k=1:K
        centro(k,:) = [mean(feat_1(ind == k)) mean(feat_2(ind == k)) mean(feat_3(ind == k))]; %new centroids
end
if centro == centro_temp %if we reach convergence
    if flag==0 %only for the first iteration of convergence
        converge = count+1; %amount of iterations to convergence
        flag = 1;
    end
    if count>8
        break
    end 
end  
count = count + 1;
end
if count == max_ans %no convergence
   sprintf('Didn''t converge before max iterations');
   converge = NaN;
   if plot_ans == 1
   sgtitle({['K-means with K = ' num2str(K)],'No Convergence!'})
   end
   return
end
if plot_ans == 1
sgtitle({['K-means with K = ' num2str(K)],['Convergence after ' num2str(converge) ' iterations!']})
end
end
