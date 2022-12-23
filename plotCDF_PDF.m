function plotCDF_PDF(X1, YMatrix1, CDF_PDF, legendName, title_CDF_PDF, LegendLabel)

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,'YGrid','on','XScale','log','XMinorTick','on','XMinorGrid','on', 'XGrid','on');
box(axes1,'on');
hold(axes1,'all');

% Create multiple lines using matrix input to semilogx
semilogx1 = semilogx(X1,YMatrix1,'Parent',axes1,'LineWidth',2);
for i = 1 : length(legendName)
    set(semilogx1(i), 'DisplayName',[LegendLabel num2str(legendName(i))]);
end

% Create xlabel
xlabel('Latency [s]');

% Create ylabel
if (CDF_PDF == 1)
    ylabel('CDF');
else
    ylabel('PDF')
end

title(title_CDF_PDF)
% Create legend
legend(axes1,'show');

end