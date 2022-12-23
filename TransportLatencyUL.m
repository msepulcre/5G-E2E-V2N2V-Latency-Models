function [lambdaTransport, Lprop, Lqueue_avg, PDFqueue, CDFqueue]= TransportLatencyUL...
        (Deployment, PktSize, x_distr, alpha, lambda_gNB)
    
%% Variables
v_fiber = 2e5;          %Fiber optic speed: [Km/s] 200.000 Km/s

%distances [Km]
d_gNB_M1 = 3;
d_gNB_M2 = 15;
d_M2_UPFulcl = 60;

% Capacity of the links [bps]
C_gNB_M1 = 10e9; 
C_M1_M2 = 300e9; 
C_M2_M3 = 6e12; 
C_M3_UPFulcl = 6e12;

%% Lprop includes the propagation and processing latencies

%K. Papagiannaki, S. Moon, C. Fraleigh, P. Thiran and C. Diot, "Measurement
% and analysis of single-hop delay on an IP backbone network," in IEEE 
%Journal on Selected Areas in Communications, vol. 21, no. 6, pp. 908-921, 
%Aug. 2003, doi: 10.1109/JSAC.2003.814410.
Tprocessing = 200e-6;   % [s] Processing time of a node

switch Deployment
    case {1, 2}
        Lproc = 4*Tprocessing;
        Lprop = Lproc + (d_gNB_M2 + d_M2_UPFulcl)/v_fiber;
    case 3
        Lproc = 2*Tprocessing;
        Lprop = Lproc + d_gNB_M1/v_fiber;
    case 4
        Lproc = Tprocessing;
        Lprop = Lproc + 0;
    otherwise
        error(['Incorrect deployment selection (' num2str(Deployment) ')'])
end
  
%% Queue analysis
alpha_gNB = alpha;

mu_gNB = (C_gNB_M1 * alpha_gNB) / PktSize; %service rate [pkts/sec]

ro_gNB = lambda_gNB / mu_gNB; % gNB server utilization

if ro_gNB >= 1
    error(['ro_gNB is higher than 1 ( ' num2str(ro_gNB) ')'])
end
    %intermediate results M/M/1
    gNB_avgDelay = 1 / (mu_gNB - lambda_gNB);

if (Deployment ~= 4) 
    %M1
    ri_M1 = 0; %There are no inputs from outside to the M1
    lambda_M1 = ri_M1 + 6 * lambda_gNB; %input rate [pkts/sec]

    alpha_M1 = alpha;

    mu_M1 = (C_M1_M2 * alpha_M1) / PktSize; %service rate [pkts/sec]

    ro_M1 = lambda_M1 / mu_M1; %M1 server utilization

    if ro_M1 >= 1
        error(['ro_M1 is higher than 1 ( ' num2str(ro_M1) ')'])
    end
    %intermediate results M/M/1
    M1_avgDelay = 1 / (mu_M1 - lambda_M1);

end

if (Deployment == 1 || Deployment == 2)
    %M2
    ri_M2 = 0; %There are no inputs from outside to the M2
    lambda_M2 = ri_M2 + 24 * lambda_M1; %input rate [pkts/sec]

    alpha_M2 = alpha;

    mu_M2 = (C_M2_M3 * alpha_M2) / PktSize; %service rate [pkts/sec]

    ro_M2 = lambda_M2 / mu_M2; %M2 server utilization

    if ro_M2 >= 1
        error(['ro_M2 is higher than 1 ( ' num2str(ro_M2) ')'])
    end
    %intermediate results M/M/1
    M2_avgDelay = 1 / (mu_M2 - lambda_M2);

    %M3
    ri_M3 = 0; %There are no inputs from outside to the M3
    lambda_M3 = ri_M3 + 12 * lambda_M2; %input rate [pkts/sec]

    alpha_M3 = alpha;

    mu_M3 = (C_M3_UPFulcl * alpha_M3) / PktSize; %service rate [pkts/sec]

    ro_M3 = lambda_M3 / mu_M3; %M3 server utilization

    if ro_M3 >= 1
        error(['ro_M3 is higher than 1 ( ' num2str(ro_M3) ')'])
    end
    %intermediate results M/M/1
    M3_avgDelay = 1 / (mu_M3 - lambda_M3);
end

%Overall queue results
switch Deployment
    case {1, 2} % 1= Centralized % 2= MEC@CN
        Lqueue_avg = gNB_avgDelay + M1_avgDelay + M2_avgDelay + M3_avgDelay;
        lambdaTransport = lambda_M3;
         
    case 3 % MEC@M1
        Lqueue_avg = gNB_avgDelay + M1_avgDelay;
        lambdaTransport = lambda_M1;
        
    case 4  % MEC@gNB
        Lqueue_avg = gNB_avgDelay;
        lambdaTransport = lambda_gNB;
end

PDFqueue = 1/Lqueue_avg .* exp( -x_distr ./ Lqueue_avg);
CDFqueue = 1 - exp( -x_distr ./ Lqueue_avg);
    
end   