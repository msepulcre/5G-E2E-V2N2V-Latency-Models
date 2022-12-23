function [PDF_conv, CDF_conv, Avg_conv, x] = ConvolutionPDF_CDF(PDF1, PDF2, step)

diffL = length(PDF1) - length(PDF2);
if diffL > 0
    PDF2 = [PDF2 zeros(1, diffL)];
elseif diffL < 0
    PDF1 = [PDF1 zeros(1, abs(diffL))];
end
PDF_conv = conv(PDF1, PDF2) * step;
CDF_conv = cumtrapz(PDF_conv) * step;
x = 0 : step : (length(PDF_conv) -1)*step;

Avg_conv = trapz(CDF_conv,x);


end