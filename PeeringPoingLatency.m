function [lpp_avg, PDFpp, CDFpp, x_step] = PeeringPoingLatency(Deployment, step)

%Reference:
%V. Giotsas, et al., “O Peer, Where Art Thou? Uncovering Remote Peering 
%Interconnections at IXPs”, IEEE-ACM Trans. Netw., vol. 29(1), pp. 1-16, Feb. 2021. 
ECDF_localPP =  [0 0.076923077 0.076923077 0.111794872 0.169230769 0.270615385 0.461538462 0.693128205 0.863589744 0.923076923 0.964102564 0.9928205 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
ECDF_remotePP = [0 0.025641026 0.030205128 0.053435897 0.066666667 0.103076923 0.117948718 0.124871795 0.142564103 0.151025641 0.163794872 0.172097949 0.176102564 0.205835897 0.217982051 0.24225641 0.300303077 0.321895385 0.356974359 0.455487179 0.629128205 0.74112 0.863927179 0.886820513 0.900358974 0.916461538 0.921948718 0.921948718 0.936564103 1];
ECDF_RTTms  = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100 200];
ECDF_s = ECDF_RTTms/2 * 1e-3;
x_step = 0 : step : max(ECDF_s);

switch Deployment
    case 1 %Remote PeeringPoing
        CDFpp = interp1(ECDF_s, ECDF_remotePP, x_step);
        lpp_avg = trapz(ECDF_remotePP,ECDF_s);
        PDFpp = diff([0 CDFpp]) / step;
    case {2, 3, 4} %Local PeeringPoing
        CDFpp = interp1(ECDF_s, ECDF_localPP, x_step);
        lpp_avg = trapz(ECDF_localPP,ECDF_s);
        PDFpp = diff([0 CDFpp]) / step;
    otherwise
        error(['Incorrect deployment selection (' num2str(Deployment) ')'])
end

end