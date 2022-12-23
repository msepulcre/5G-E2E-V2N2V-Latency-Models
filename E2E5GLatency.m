function E2E5GLatency(alpha, ...
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
        
%% Variables
max_delay = Tpkt + (nRep+1)*slot; %[s]  
x_distr = 0 : step : max_delay; %[s]

%% **************** RAN Radio latency *************************************

[lambda_gNB_RANradioUL, ...
RANradio_LatMeanUL, RANradio_LatMeanDL, ...
RadioYCDF_UL, RadioXCDF_UL, ...
RadioYCDF_DL, RadioXCDF_DL, ...
RANradioULDL_LatMean, RANradioULDL_LatPrctl]=...
    RadioLatency(LoadRadioValues, Highway_UrbanGrid, Density, ISD, PktSize,...
                Tpkt, traffic, BW, SCS, Ncopies, MCS_table, MIMOlayers, nRep, nRtx);

if LoadRadioValues == 1              
    RANradioULDL_LatMean = RANradio_LatMeanUL + RANradio_LatMeanDL;
    
    RANradio_LatPrctlUL = CDF2PercValue(RadioYCDF_UL, RadioXCDF_UL, Percentile);
    RANradio_LatPrctlDL = CDF2PercValue(RadioYCDF_DL, RadioXCDF_DL, Percentile);
    RANradioULDL_LatPrctl = RANradio_LatPrctlUL + RANradio_LatPrctlDL;
end

%% **************** Tranport Network Latnency UL **************************

[lambdaTransportUL, LpropTransportUL, Lqueue_avgTransportUL, ~, CDFqueueTransport] = ...
TransportLatencyUL(Deployment, PktSize, x_distr, alpha, lambda_gNB_RANradioUL);

TransportUL_LatMean = LpropTransportUL + Lqueue_avgTransportUL;

Lqueue_PrctlTransportUL = CDF2PercValue(CDFqueueTransport, x_distr, Percentile);
TransportUL_LatPrctl = LpropTransportUL + Lqueue_PrctlTransportUL;

%% ******************* Core Network UL ************************************

[lambdaCoreUL, LpropCoreUL, Lqueue_avgCoreUL, ~, CDFqueueCoreUL] = ...
CoreLatency(Deployment, PktSize, lambdaTransportUL, x_distr, alpha);

CoreUL_LatMean = LpropCoreUL + Lqueue_avgCoreUL;

Lqueue_PrctlCoreUL = CDF2PercValue(CDFqueueCoreUL, x_distr, Percentile);
CoreUL_LatPrctl = LpropCoreUL + Lqueue_PrctlCoreUL;

%% ******************* V2X AS *********************************************

%lV2X_AS < t_tt
[lAPP_avg, ~, ~, lambdaV2XAS, YCDF, XCDF, ~] = ...
    V2XASLatency(Deployment, PktSize, lambdaCoreUL, x_distr,BroadMulticast_Unicast, Ncopies, slot);

Lv2xAS_Prctl = CDF2PercValue(YCDF, XCDF, Percentile);
%Lv2xAS_Prctl = CDF2PercValue(CDFapp, x_distr, Percentile);

%% ******************* Core Network DL ***********************************

%For DL unicast, each packet generates Ncopies
if BroadMulticast_Unicast == 1 % For each pkt in the UL, one pkt in the DL
    %Symmetric: same performance than in the UL
    lambdaCoreDL = lambdaV2XAS;
    LpropCoreDL = LpropCoreUL;
    Lqueue_avgCoreDL = Lqueue_avgCoreUL;
    CDFqueueCoreDL = CDFqueueCoreUL;

elseif BroadMulticast_Unicast == 2 
    [lambdaCoreDL, LpropCoreDL, Lqueue_avgCoreDL, ~, CDFqueueCoreDL] = ...
    CoreLatency(Deployment, v_fiber, PktSize, lambdaV2XAS, x_distrOriginal, redundancy, alpha);
end

CoreDL_LatMean = LpropCoreDL + Lqueue_avgCoreDL;

Lqueue_PrctlCoreDL = CDF2PercValue(CDFqueueCoreDL, x_distr, Percentile);
CoreDL_LatPrctl = LpropCoreDL + Lqueue_PrctlCoreDL;
     
%% ******************* Transport Network DL *******************************

[LpropTransportDL, Lqueue_avgTransportDL, ~, CDFqueueTransportDL]= ...
TransportLatencyDL(Deployment, PktSize, lambdaCoreDL, x_distr, alpha);

TransportDL_LatMean = LpropTransportDL + Lqueue_avgTransportDL;

Lqueue_PrctlTransportDL = CDF2PercValue(CDFqueueTransportDL, x_distr, Percentile);
TransportDL_LatPrctl = LpropTransportDL + Lqueue_PrctlTransportDL;

%% ********************** Peering Poing ***********************************

[lpp_avg, ~, CDFpp, x_pp]...
= PeeringPoingLatency(Deployment, x_distr(2) - x_distr(1));

PeeringPoint_Prctl = CDF2PercValue(CDFpp, x_pp, Percentile);  

%% *************************** Internet ***********************************

if Deployment == 1 %Centralized
    
    [UpfAs_avg, ~, CDF_UpfAs, x_UpfAs]=InterneLatency(x_distr(2) - x_distr(1));
    UpfAs_Prctl = CDF2PercValue(CDF_UpfAs, x_UpfAs, Percentile);
end

%% *************************** End-to-end *********************************

% Average performance
TransportULDL_LatMean = TransportUL_LatMean + TransportDL_LatMean;
CoreULDL_LatMean = CoreUL_LatMean + CoreDL_LatMean;

E2E_LatMean_SingleMNO = RANradioULDL_LatMean + TransportULDL_LatMean + CoreULDL_LatMean + ...
              lAPP_avg;
E2E_LatMean_MultiMNO = E2E_LatMean_SingleMNO + lpp_avg;
if Deployment == 1 % Centralized
    E2E_LatMean_SingleMNO = E2E_LatMean_SingleMNO + UpfAs_avg;
    E2E_LatMean_MultiMNO = E2E_LatMean_MultiMNO + UpfAs_avg;
end

%Percentile
TransportULDL_LatPrctl = TransportUL_LatPrctl + TransportDL_LatPrctl;
CoreULDL_LatPrctl = CoreUL_LatPrctl + CoreDL_LatPrctl;

E2E_LatPrctl_SingleMNO = RANradioULDL_LatPrctl + TransportULDL_LatPrctl + CoreULDL_LatPrctl + ...
              Lv2xAS_Prctl;
E2E_LatPrctl_MultiMNO = E2E_LatPrctl_SingleMNO + PeeringPoint_Prctl;
if Deployment == 1 % Centralized
    E2E_LatPrctl_SingleMNO = E2E_LatPrctl_SingleMNO + UpfAs_Prctl;
    E2E_LatPrctl_MultiMNO = E2E_LatPrctl_MultiMNO + UpfAs_Prctl;
end

%% Print output tables for average and prctl latency values

Deployment_string = ["Centralized"; "MEC@CN"; "MEC@M1"; "MEC@gNB"];
if Deployment ~= 1
    LatComponent = ["Lradio"; "Ltn"; "Lcn"; "Las"; "Le2e_1MNO"; "Lpp"; "Le2e_2MNO"];
    LatAvgValues_ms = 1e3*[RANradioULDL_LatMean; TransportULDL_LatMean; CoreULDL_LatMean; lAPP_avg; E2E_LatMean_SingleMNO; lpp_avg; E2E_LatMean_MultiMNO];
    LatPrctlValues_ms = 1e3*[RANradioULDL_LatPrctl; TransportULDL_LatPrctl; CoreULDL_LatPrctl; Lv2xAS_Prctl; E2E_LatPrctl_SingleMNO; PeeringPoint_Prctl; E2E_LatPrctl_MultiMNO];
else
    LatComponent = ["Lradio"; "Ltn"; "Lcn"; "Lupf-as"; "Las"; "Le2e_1MNO"; "Lpp"; "Le2e_2MNO"];
    LatAvgValues_ms = 1e3*[RANradioULDL_LatMean; TransportULDL_LatMean; CoreULDL_LatMean; UpfAs_avg; lAPP_avg; E2E_LatMean_SingleMNO; lpp_avg; E2E_LatMean_MultiMNO];
    LatPrctlValues_ms = 1e3*[RANradioULDL_LatPrctl; TransportULDL_LatPrctl; CoreULDL_LatPrctl; UpfAs_Prctl; Lv2xAS_Prctl; E2E_LatPrctl_SingleMNO; PeeringPoint_Prctl; E2E_LatPrctl_MultiMNO];
end

str=strcat( "E2E average latency (in MS) for the " , Deployment_string(Deployment) , " deployment (alpha=" , num2str(alpha) , ")" );
disp(str)
table(LatComponent, LatAvgValues_ms)

str=strcat( num2str(100*Percentile) , "th prctl of E2E latency (in MS) for the " , Deployment_string(Deployment) , " deployment (alpha=" , num2str(alpha ), ")" );
disp(str)
table(LatComponent, LatPrctlValues_ms)

end