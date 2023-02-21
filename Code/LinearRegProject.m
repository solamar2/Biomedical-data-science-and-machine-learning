function [theta,J,theta_mat] = LinearRegProject(X,y,p,alpha)
%% This function creates linear regression model
%% inputs:
% X - training data - after we create a linear fit of y we will use this
% type of datas to find approximation of y type of data.
% y - a sample of the type of data we are creating a linear fit of.
% p - the amount of iterations used in the gradiant decent.
% alpha - the alpha that belong to the update function - will affect how
% great a change each itteration will invoke in the value of theta.
%% outputs:
% theta - the coefficient vector that defines the linear approximation.
% J - the cost function vector (for each iteration
% theta_mat - a matrix whom each raw contains the thetas of each iteration
%%
m = size(X,1);
n = length(y);
l = size(X,2)+1; % # of features
J = zeros(p,1); %initialziation of cost function vector
theta_mat = zeros(p,l);
if m~=n
   error('incorrect inputs!');
end
X = [ones(m,1) X];
theta = zeros(1,l); % theta intialization
h_x = sum(theta.*X,2); %prediction function initialization
theta_temp = theta;
for k=1:p %number of iterations
for j=1:l %number of features + 1 
    for i = 1:m
    theta_temp(j) = theta_temp(j)-alpha*(1/m)*(h_x(i)-y(i))*X(i,j); %update function 
    end
end
   theta = theta_temp; %updating the theta after going through all the thetas with one iteration
   theta_mat(k,:) = theta;
   h_x = sum(theta.*X,2); % updating the prediction function
   J(k) = 1/(2*m)*sum((h_x-y).^2); %cost function
end
end