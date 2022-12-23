function main
clc    
close all
format long
tic
%% Deployment
% 1=> Centralized 
% 2=> MEC@CN
% 3=> MEC@M1
% 4=> MEC@gNB
Deployment = 1;

%% Traffic characteristics
BroadMulticast_Unicast = 1; % {1 (DL is BroadMulticast), 2 (DL is unicast)} 
Ncopies = 1;                % Num of copies of the transmitted UL packet/gNB (i.e. DL receivers of the UL transmission)

if BroadMulticast_Unicast == 1
    Ncopies = 1;
end

PktSize = 300 * 8;  %Packet size: {300bytes, 600bytes} [bits]
Tpkt  = 100 * 1e-3; %Packet interval: {100ms, 50ms, 20ms} [s]         
traffic = 1;        %traffic type: {0 aperiodic, 1 periodic} 
                        %RAN-radio traffic generation in UL

%% Scenario
Highway_UrbanGrid = 1;  %{1 (Highway), 2 (UrbanGrid)}
Density  =  80;         %Vehicle Density: Highway{10, 20, 40, 60, 80} veh/(km*lane)
                        %                 UrbanGrid40kmph -> 90veh/km*lane
                        %                 UrbanGrid60kmph -> 60.2 veh/km*lane
ISD =   1.732;          %Highway InterSiteDistance: {1.732, 0.5} 
                        %UrbanGrid InterSiteDistance {0.5}                    
                        
%% Reliability configuration
Percentile = 0.9999; % {0.9 , 0.9999}
MCS_table = 3; % 2 (BLER 10%), 3 (BLER 0.01%)

%% Transport and Core network configuration
    %ratio of the links capacities that is allocated to support the traffic 
    % of the V2X service in UL and DL
alpha = 0.01;

%% Radio configuration

%Number of replicas
nRep = 1; %1, 2, 4
%Number of HARQ retransmissions
nRtx = 0; %HARQ

% scs: subcarrier-spacing = {15, 30, 59, 60} [KHz] 
%   ->(15, 30 and 60) use Normal Cyclic Prefix (NCP);  
%   -> '59' indicates SCS 60 KHz with Extended CP (ECP)
SCS = 30;   
if SCS == 59
    CP = 'ECP'; %{'ECP', 'NCP'}
else
    CP = 'NCP';
end

%minislot configuration
minislot_config = 0; %{0 (OFF), 1 (ON)}

%N_OS: Number of OFDM symbols
switch minislot_config
    case 0
        switch CP
            case 'NCP'
                N_OS=14;
            case 'ECP'
                N_OS=12;
        end
    case 1
        switch CP
            case 'NCP'
                N_OS=7;
            case 'ECP'
                N_OS=6;
        end
    case 2
        N_OS=4;
    case 3
        N_OS=2;
end

%slot duration [s]
switch SCS
    case 15
        slot = (1e-3)*N_OS/14;
    case 30
        slot = (0.5e-3)*N_OS/14;
    case 59
        slot = (0.25e-3)*N_OS/12;
    case 60
        slot = (0.25e-3)*N_OS/14;
end

%Bandwidth {10, 20, 30, 40,...}
BW = 20; 

%MIMO layers
MIMOlayers = 2; %1:8

%LoadRadioValues: if sets to 1 it takes the radio latency performance from
% the simulations running in the 5G-NR-Radio-Latency-Models. Otherwise, 
%these values must be indicated by the user (see RadioLatency.m) 
    %1: values from 5G-NR-Radio-Latency-Models (https://github.com/msepulcre/5G-NR-Radio-Latency-Models)
    %       You have to copy the output 5G NR radio latency file: 
    %                'latency_RANradio_scen*.mat' 
    %       in the folder:
    %               ./RadioToE2Emodel  
LoadRadioValues = 0;


             
%% Simulation time granurality
step = 1e-5; %[s] to be used in CDFs & PDFs 

%% Diary file
diary_file=['Dep' num2str(Deployment) '_alpha' num2str(alpha) ...
        '_BoU' num2str(BroadMulticast_Unicast) '_Ncpy' num2str(Ncopies) ...
        '_PktS' num2str(PktSize) '_T' num2str(Tpkt) ...
        '_HoU' num2str(Highway_UrbanGrid) '_Density' num2str(Density)  ...
        '_ISD' num2str(ISD) '_step' num2str(step) '_trf' num2str(traffic) ...
        '_scs' num2str(SCS) '_bw' num2str(BW) '_mcsT' num2str(MCS_table) ...
        '_mimol' num2str(MIMOlayers) '_nRep' num2str(nRep) '_nRtx' num2str(nRtx) '.txt'];
diary(diary_file)
diary on

%%
Deployment_string = ["Centralized"; "MEC@CN"; "MEC@M1"; "MEC@gNB"];

disp('**************** Scenario ******************************')

disp(strcat("Deployment: ", Deployment_string(Deployment)))
disp(['DL is 1-BroadMulticast_2-Unicast: ' num2str(BroadMulticast_Unicast)])
disp(['Ncopies/gNB (only for Unicast): ' num2str(Ncopies)])
disp(['Highway_UrbanGrid: ' num2str(Highway_UrbanGrid)])
disp(['Density: ' num2str(Density)])
disp(['PktSize: ' num2str(PktSize)])
disp(['Tpkt: ' num2str(Tpkt)])
disp(['alpha : ' num2str(alpha)])
disp(['Percentile : ' num2str(Percentile)])
disp(['MCS : ' num2str(MCS_table)])
disp(['Pkt rate (highway): ' num2str( Density*3 * 2 * 1.732/Tpkt) ])
disp('********************************************************')

%%
E2E5GLatency(alpha, ...
            Deployment, ...
            BroadMulticast_Unicast, ...
            Ncopies, ...
            PktSize, ...
            Tpkt, ...
            Highway_UrbanGrid, ...
            Density, ...
            ISD, ...
            step, ...
            traffic, ...
            SCS, ...
            BW, ...
            MCS_table, ...
            MIMOlayers, ...
            nRep,...
            nRtx, ...
            slot, ...
            LoadRadioValues, ...
            Percentile)

toc
diary off

end