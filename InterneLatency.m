function [UpfAs_avg, PDF_UpfAs, CDF_UpfAs, x_UpfAs]=InterneLatency(step)

%Load RTT measurements from:
%Massimo Candela, Valerio Luconi, Alessio Vecchio, “Impact of the COVID-19 
%pandemic on the Internet latency: A large-scale study”, Computer Networks,
% vol. 182, Dec. 2020, doi: https://doi.org/10.1016/j.comnet.2020.107495
measurements=load('RTT_Internet.mat');
[f,x]=ecdf(measurements.RTT_Internet.Italy); %x RTT in ms;
x_s = x * 1e-3;
if x_s(1) == x_s(2) %The grid vectors must contain unique points.
    x_s(1)=0;
end

x_UpfAs = 0 : step : max(x_s);

CDF_UpfAs = interp1(x_s, f, x_UpfAs);
UpfAs_avg = trapz(f,x_s);
PDF_UpfAs = diff([0 CDF_UpfAs]) / step;

end
