function [f,F] = EstimateDistribution(X,x)
% This function implements estimation of CDF and PDF of one dimensional 
% random variables.
%
% INPUTS:
%           X = vector specifying random variables
%           x = vector specifying points for which CDF and PDF has to be
%               evaluated
% OUTPUTS:
%           f = vector specifying estimated PDF of random variable X for
%               points.
%           F = vector specifying estimated CDF of random variable X for
%               points.

% Impelementation Starts Here
f = zeros(1,length(x)); % Preallocation of memory space
F = f;                  % Preallocation of memory space
%h = max(X)/1e6; % Small value closer to zero for evaluating
% numerical differentiation.

%v1 Estimating CDF by its definition
% for m = 1:length(x)
%     p = 0;              % True Probability
%     q = 0;              % False Probability
%     for n = 1:length(X)
%         if X(n)<=x(m)   % Definition of CDF
%             p = p + 1;
%         else
%             q = q + 1;
%         end
%     end
%     F(m) = p/(p + q);   % Calulating Probability
% end

%v2
for m = 1:length(x)
    p = length(find(X <=x(m)));
    F(m) = p;
    if p == length(X)
        F(m:end) = p;
        break
    end
end
F = F/length(X);

%figure;
%plot(x,F);

% Estimating PDF by differentiation of CDF
f = diff([0 F])/(x(2) - x(1)); % /x(2) - x(1) % Numerical differentiation
%figure;
%plot(x,f);                             % Smoothing at last
    
end