function [lambda_gNB_RANradioUL, RANradioUL_LatMean, RANradioDL_LatMean, ...
    RadioYCDF_UL, RadioXCDF_UL, ...
    RadioYCDF_DL, RadioXCDF_DL, ...
    RANradioULDL_LatMean, RANradioULDL_LatPrctl]=RadioLatency(LoadRadioValues, ...
                                          Highway_UrbanGrid, ...
                                          Density, ...
                                          ISD, ...
                                          PktSize, ...
                                          Tpkt, ...
                                          traffic, ...
                                          BW, ...
                                          SCS, ...
                                          Ncopies, ...
                                          MCS_table, ...
                                          MIMOlayers,...
                                          nRep, ...
                                          nRtx)
                                      

if LoadRadioValues == 1
    RANradioULDL_LatMean = NaN;
    RANradioULDL_LatPrctl = NaN;
    cd RadioToE2Emodel\
    
    %% escenario %{0 (circular), 11 (highway1732), 12 (highway500), 21 (urban500)}
    switch Highway_UrbanGrid
        case 1 %Highway
            if ISD == 1.732
                escenario = 13; % %13 highway1732_3lanes
            elseif ISD == 0.5
                escenario = 12;
            else
                error("Wrong ISD configuration for Highway scenario")    
            end
        case 2 %UrbanGrid
            escenario = 21;
        otherwise
            escenario = 0;
    end

    %% uplink
    link_direction = 2; %{1 downlink, 2 uplink}    
    load (['latency_RANradio_scen' num2str(escenario) '_LnkDir' num2str(link_direction) ...
    '_nDLTx1_traffic' num2str(traffic) '_Tp' num2str(Tpkt * 1e3) ...
    '_SCS' num2str(SCS) '_BW' num2str(BW) '_density' num2str(Density) ...
    '_MCSTable' num2str(MCS_table) '_layers' num2str(MIMOlayers) ...
    '_rep' num2str(nRep) '_retx' num2str(nRtx) '_pkt' num2str(PktSize/8) ...
    '.mat'], ...
    'YCDF', 'XCDF', 'RANradio_LatMean', 'ri_gNB_RANradio') ;
    % Available variables in the .mat file:
        % 'YCDF',...
        % 'XCDF',...
        % 'RANradio_LatMean',...
        % 'ri_gNB_RANradio','ri_gNB_RANradio2',...
        % 'ri_gNB_RANradioMAX','ri_gNB_RANradioMAX2',...
        % 'ri_gNB_RANradioMIN','ri_gNB_RANradioMIN2'
    
    lambda_gNB_RANradioUL = ri_gNB_RANradio;
    RANradioUL_LatMean = RANradio_LatMean * 1e-3; %[s]
    RadioYCDF_UL = YCDF;
    RadioXCDF_UL = XCDF * 1e-3; %[s] 

    %% Downlink
    link_direction = 1; %{1 downlink, 2 uplink}
    load(['latency_RANradio_scen' num2str(escenario) '_LnkDir' num2str(link_direction) ...
    '_nDLTx' num2str(Ncopies) '_traffic' num2str(traffic) '_Tp' num2str(Tpkt * 1e3) ... 
    '_SCS' num2str(SCS) '_BW' num2str(BW) '_density' num2str(Density) ...
    '_MCSTable' num2str(MCS_table) '_layers' num2str(MIMOlayers) ...
    '_rep' num2str(nRep) '_retx' num2str(nRtx) '_pkt' num2str(PktSize/8) ...
    '.mat'], ...
    'YCDF', 'XCDF', 'RANradio_LatMean');
    % Available variables in the .mat file:
        % 'YCDF',...
        % 'XCDF',...
        % 'RANradio_LatMean',...
        % 'ri_gNB_RANradio','ri_gNB_RANradio2',...
        % 'ri_gNB_RANradioMAX','ri_gNB_RANradioMAX2',...
        % 'ri_gNB_RANradioMIN','ri_gNB_RANradioMIN2'
        
    RANradioDL_LatMean = RANradio_LatMean * 1e-3; %[s]
    RadioYCDF_DL = YCDF;
    RadioXCDF_DL = XCDF * 1e-3; %[s]    
    
    cd ..

else %% Insert manually the radio latency values & percentiles
   
    %Determine UEs: Number of UEs within the cell
    switch Highway_UrbanGrid
        case 1 % Highway
            UEs = ceil(3 * 2 * ISD); % 3 lanes x 2 directions            
        case 2 % UrbanGrid
            UEs = ceil(2 * 2 * ISD); % 2 lanes x 2 directions
        otherwise
            error('Wrong Highway_UrbanGrid configuration')
    end
    UEs = UEs * Density;
    
   
    lambda_gNB_RANradioUL = UEs/Tpkt; %input packets per second [pkts/sec]

    %Tables IV & XV (https://doi.org/10.1109/TVT.2022.3224614) for Highway
    if MCS_table == 2 %Low Level of Automation
        if Tpkt == 0.1
            switch Density
                case 10
                    RANradioULDL_LatPrctl = 2.00;
                    RANradioULDL_LatMean = 1.50;
                case 20
                    RANradioULDL_LatPrctl = 2.00;
                    RANradioULDL_LatMean = 1.50;
                case 40
                    RANradioULDL_LatPrctl = 2.00;
                    RANradioULDL_LatMean = 1.50;
                case 60
                    RANradioULDL_LatPrctl = 2.00;
                    RANradioULDL_LatMean = 1.50;
                case 80
                    RANradioULDL_LatPrctl = 2.00;
                    RANradioULDL_LatMean = 1.50;
            end
        elseif Tpkt == 0.02
            switch Density
                case 10
                    RANradioULDL_LatPrctl = 2.00;
                    RANradioULDL_LatMean = 1.50;
                case 20
                    RANradioULDL_LatPrctl = 2.00;
                    RANradioULDL_LatMean = 1.50;
                case 40
                    RANradioULDL_LatPrctl = 2.32;
                    RANradioULDL_LatMean = 1.50;
                case 60
                    RANradioULDL_LatPrctl = 6.07;
                    RANradioULDL_LatMean = 1.56;
                case 80
                    RANradioULDL_LatPrctl = NaN;
                    RANradioULDL_LatMean = 3.09;
            end
        end
        
    elseif MCS_table == 3 % High Level of Automation
        if Tpkt == 0.1
            switch Density
                case 10
                    RANradioULDL_LatPrctl = 2.60;
                    RANradioULDL_LatMean = 1.50;
                case 20
                    RANradioULDL_LatPrctl = 2.77;
                    RANradioULDL_LatMean = 1.50;
                case 40
                    RANradioULDL_LatPrctl = 3.08;
                    RANradioULDL_LatMean = 1.51;
                case 60
                    RANradioULDL_LatPrctl = 3.58;
                    RANradioULDL_LatMean = 1.52;
                case 80
                    RANradioULDL_LatPrctl = 4.55;
                    RANradioULDL_LatMean = 1.58;
            end
        elseif Tpkt == 0.02
            switch Density
                case 10
                    RANradioULDL_LatPrctl = 3.58;
                    RANradioULDL_LatMean = 1.53;
                case 20
                    RANradioULDL_LatPrctl = 12.27;
                    RANradioULDL_LatMean = 1.67;
                case 40
                    RANradioULDL_LatPrctl = NaN;
                    RANradioULDL_LatMean = 7.31;
                case 60
                    RANradioULDL_LatPrctl = NaN;
                    RANradioULDL_LatMean = 11.81;
                case 80
                    RANradioULDL_LatPrctl = NaN;
                    RANradioULDL_LatMean = 14.23;
            end
        end
    end
    RANradioULDL_LatMean = RANradioULDL_LatMean * 1e-3; %[s]
    RANradioULDL_LatPrctl = RANradioULDL_LatPrctl * 1e-3; %[s]
    
    RANradioUL_LatMean = NaN;
    RANradioDL_LatMean = NaN;
    RadioYCDF_UL = NaN;
    RadioXCDF_UL = NaN;
    RadioYCDF_DL = NaN;
    RadioXCDF_DL = NaN;
end

end