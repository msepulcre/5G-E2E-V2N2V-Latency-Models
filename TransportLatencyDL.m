function [Lprop, Lqueue_avg, PDFqueue, CDFqueue]=TransportLatencyDL ...
    (Deployment, PktSize, lambdaCore, x_distr, alpha)

%% Variables
v_fiber = 2e5;          %Fiber optic speed: [Km/s] 200.000 Km/s

%distances [Km]
d_UPFulcl_M2 = 60;
d_M2_gNB = 15;
d_M1_gNB = 3;

% Capacity of the links [bps]
C_M3_M2 = 6e12; 
C_M2_M1 = 300e9; 
C_M1_gNB = 10e9; 

%% Lprop includes the propagation and processing latencies

%K. Papagiannaki, S. Moon, C. Fraleigh, P. Thiran and C. Diot, "Measurement
% and analysis of single-hop delay on an IP backbone network," in IEEE 
%Journal on Selected Areas in Communications, vol. 21, no. 6, pp. 908-921, 
%Aug. 2003, doi: 10.1109/JSAC.2003.814410.
Tprocessing = 200e-6;   % [s] Processing time of a node

switch Deployment
    case {1, 2}
        Lproc = 4*Tprocessing;
        Lprop = Lproc + (d_UPFulcl_M2 + d_M2_gNB)/v_fiber;
    case 3
        Lproc = 2*Tprocessing;
        Lprop = Lproc + d_M1_gNB/v_fiber;
    case 4
        Lproc = Tprocessing;
        Lprop = Lproc +  0;
    otherwise
        error(['Incorrect deployment selection (' num2str(Deployment) ')'])
end

%% Queue analysis
if (Deployment == 1 || Deployment == 2)
    %M3
    ri_M3 = lambdaCore / 12; %Towards the next M2 there are two agg rings, and each comprises 6 M2
    lambda_M3 = ri_M3; %input rate [pkts/sec]
    alpha_M3 = alpha;
    mu_M3 = (C_M3_M2 * alpha_M3) / PktSize; %service rate [pkts/sec]
    ro_M3 = lambda_M3 / mu_M3; %server utilization

    if ro_M3 >= 1
        error(['ro_M3 is higher than 1 (' num2str(ro_M3) ')'])
    end
    %intermediate results M/M/1
    M3_avgDelay = 1 / (mu_M3 - lambda_M3);

    %M2
    ri_M2 = 0; %There are no inputs from outside to the M2
    lambda_M2 = ri_M2 + lambda_M3 / 24; %Towards the next M1 is 1/24 the input rate
    alpha_M2 = alpha; 
    mu_M2 = (C_M2_M1 * alpha_M2) / PktSize; %service rate [pkts/sec]
    ro_M2 = lambda_M2 / mu_M2; %server utilization

    if ro_M2 >= 1
        error(['ro_M2 is higher than 1 (' num2str(ro_M2) ')'])
    end
    %intermediate results M/M/1
    M2_avgDelay = 1 / (mu_M2 - lambda_M2);
end

%M1
if (Deployment ~= 4)
    if (Deployment == 1 || Deployment == 2)
        ri_M1 = 0; %There are no inputs from outside to the M2
        lambda_M1 = ri_M1 + lambda_M2 / 6; %Towards the next gNB is 1/6 the input rate
    elseif Deployment == 3
        ri_M1 = lambdaCore / 6; %Towards the next gNB is 1/6 the input rate;
        lambda_M1 = ri_M1;
    end
    alpha_M1 = alpha; %
    mu_M1 = (C_M1_gNB * alpha_M1)/PktSize; %service rate [pkts/sec]
    ro_M1 = lambda_M1 / mu_M1; %server utilization

    if ro_M1 >= 1
        error(['ro_M1 is higher than 1 (' num2str(ro_M1) ')'])
    end
    %intermediate results M/M/1
    M1_avgDelay = 1 / (mu_M1 - lambda_M1);
end

%Overall queue results
switch Deployment
    case {1, 2} % Cent & MEC@CN
        Lqueue_avg = M3_avgDelay + M2_avgDelay + M1_avgDelay; %+ gNB_avgDelay;
        
    case 3 % MEC@M1
        Lqueue_avg =  M1_avgDelay; 
                
    case 4 % MEC@gNB
        Lqueue_avg = 0; 
end

PDFqueue = 1/Lqueue_avg .* exp( -x_distr ./ Lqueue_avg);
CDFqueue = 1 - exp( -x_distr ./ Lqueue_avg );

end