
clear all   %clear workspace
clc         %clear command window     


      load AE2017_assign_p1
      total = size(data);
      N = total(2);
      T = 50;
      Errors = zeros(T,N);
      MSE_mat = zeros(N,2);
      param_mat = zeros(N,6);
      llik_mat = zeros(N,1);
for i =1:N        
%% 2. Optimization Options

      options = optimset('Display','iter',... %display iterations
                         'TolFun',1e-9,... % function value convergence criteria 
                         'TolX',1e-9,... % argument convergence criteria
                         'MaxIter',500); % maximum number of iterations    

%% 4. Initial Parameter Values
      
      x = data(:,i);  % first column of dataset

      alpha_ini = 0;  % initial value for intercept
      beta_ini = 0;   % initial value for ar coefficient
      sig_ini = 1;    % initial value for innovation variance
      
      theta_ini = [alpha_ini,beta_ini,sig_ini];
      

      lb=[-1000,-100,0.00001];  % lower bound for theta
      ub=[1000,1000,1000];        % upper bound for theta
      

      [theta_hat,llik_val,exitflag]=...
          fmincon(@(theta) - llik_fun_AR1(x,theta),theta_ini,[],[],[],[],lb,ub,[],options);
      


      alpha_ini = theta_hat(1);  % initial value for intercept
      beta_ini = theta_hat(2);   % initial value for ar coefficient
      sig_ini = theta_hat(3);    % initial value for innovation variance
      delta_ini = 0;
      gamma_ini = 0;
      mu_ini = 0;

      theta_ini = [alpha_ini,beta_ini,sig_ini,delta_ini,gamma_ini,mu_ini];

      lb=[-1000,-1000,0.00001,-1000,-1000,-1000];  % lower bound for theta
      ub=[1000,1000,1000,1000,1000,1000];        % upper bound for theta
      

      [theta_hat2,llik_val2,exitflag2]=...
          fmincon(@(theta) - llik_fun_SESTAR(x,theta),theta_ini,[],[],[],[],lb,ub,[],options);
       
%% 7. Forecast 

alpha=theta_hat2(1);
beta=theta_hat2(2);
delta=theta_hat2(4);
gamma=theta_hat2(5);
mu=theta_hat2(6);
sigma=theta_hat2(3);

T = 50;
epsilon = sigma*randn(T,1);
xf = zeros(T,1);
xf(1) = x(end);
g = zeros(T,1);
g(1) = 0
xr = data(456:end,1);
    for t=2:T % start recursion from t=2 to t=T
        
       xf(t) =  alpha + g(t-1) * (xf(t-1)-mu) + epsilon(t); % generate x(t) recursively
       g(t) = delta + (gamma/(1+exp(beta*(x(t-1)-mu)^2)));
       %u=x(2:end) - alpha - g*(x(1:end-1)-mu); 
       
    end % end recursion


MSE = mean((xf-xr).^2)
RMSE = sqrt(MSE)
MSE_mat(i,1) = MSE;
MSE_mat(i,2) = RMSE;
f_error = xf-xr;
Errors(:,i) = f_error;

param_mat(i,1) = alpha;
param_mat(i,2) = beta;
param_mat(i,3) = delta;
param_mat(i,4) = gamma;
param_mat(i,5) = mu;
param_mat(i,6) = sigma;

llik_mat(i) = llik_val;

end

DM_Scores = zeros(N,N);
for i=1:N
   for j=1:N 
        DM_Scores(i,j) = DM(Errors(:,i),Errors(:,j),1);
   end
end
DM_Scores
MSE_mat
param_mat
llik_mat
%% 8. Print Output


%figure1 = figure(1);
%set(figure1)
%subplot(2,1,1)
%plot(xf,'b')
%title('Forecasted')
%subplot(2,1,2)
%plot(xr,'r')
%title('Realized')      


%display('parameter estimates:')
%theta_hat

%display('log likelihood value:')
%llik_val

%display('exit flag:')
%exitflag


