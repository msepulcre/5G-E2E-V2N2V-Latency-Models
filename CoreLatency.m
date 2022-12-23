function [lambdaCore, Lprop, Lqueue_avg, PDFqueue, CDFqueue]=CoreLatency...
        (Deployment, PktSize, lambdaTransport, x_distr, alpha)


%% Variables
v_fiber = 2e5;              %Fiber optic speed: [Km/s] 200.000 Km/s
d_UPFulcl_UPFcent = 200;    %[Km]
Max_dist_betweenUPFs = 70;  %[Km]

% Capacity of the links [bps]
C_core = 6e12;
alpha_core = alpha;

%% Lprop
switch Deployment
    case 1
        Lprop = (d_UPFulcl_UPFcent)/v_fiber;
    case {2, 3, 4}
        Lprop = 0;
    otherwise
        error(['Incorrect deployment selection (' num2str(Deployment) ')'])
end

%% Queue analysis

%UPFulcl
ri_UPFulcl = 0; %There are no inputs from outside to the UPF
lambda_UPFulcl = ri_UPFulcl + lambdaTransport;

mu_UPFulcl = (C_core * alpha_core) / PktSize; %service rate [pkts/sec]
    
ro_UPFulcl = lambda_UPFulcl / mu_UPFulcl; %UPFulcl server utilization

if ro_UPFulcl >= 1
    error(['ro_UPFulcl is higher than 1 (' num2str(ro_UPFulcl) ')'])
end
    %intermediate results M/D/1
    UPFulcl_avgDelay = ...
                        1 / mu_UPFulcl + ...  %Processing
                        lambda_UPFulcl / (2 * mu_UPFulcl^2 * (1 - ro_UPFulcl)) + ... %Queueing
                        1 / mu_UPFulcl;     % transmission
    
if Deployment == 1    
    %links and switches between UPFs
    
    %number of intermediate switches
    n = ceil (d_UPFulcl_UPFcent / Max_dist_betweenUPFs) - 1 ; 

    %intermediate results
    Switch_avgDelay = 2 * n / mu_UPFulcl;

    %UPFcent
    ri_UPFcent = 0; %There are no inputs from outside to the UPF
    lambda_UPFcent = ri_UPFcent + lambda_UPFulcl;

    mu_UPFcent = (C_core * alpha_core) / PktSize; %service rate [pkts/sec]

    ro_UPFcent = lambda_UPFcent / mu_UPFcent; %UPFcent server utilization

    if ro_UPFcent >= 1
        error(['ro_UPFcent is greater than 1 (' num2str(ro_UPFcent) ')'])
    end
        %intermediate results M/D/1
        UPFcent_avgDelay = ...
                            1 / mu_UPFcent + ...  %Processing
                            1 / mu_UPFcent;     % transmission
end
 
switch Deployment
    case 1 % 1= Centralized (Cent)
        Lqueue_avg = UPFulcl_avgDelay + Switch_avgDelay + UPFcent_avgDelay;
        lambdaCore = lambda_UPFcent;
    case {2, 3, 4} % MEC@{CN, M1, gNB}
        Lqueue_avg = UPFulcl_avgDelay;
        lambdaCore = lambda_UPFulcl;
end   

%Distribution
Norm_lambda = ro_UPFulcl;
samples=1000; 
[~, ~, systtime_norm] = simmd1(samples, Norm_lambda);
UPFulcl_systime = systtime_norm * 1/mu_UPFulcl;

[PDFqueue,CDFqueue] = EstimateDistribution(UPFulcl_systime,x_distr);

end