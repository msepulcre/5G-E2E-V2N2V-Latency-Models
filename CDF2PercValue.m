function [PercValue]=CDF2PercValue(CDFdistY,CDFdistX, Perc)

aux=find(CDFdistY >= Perc, 1);
if isempty(aux) || aux == length(CDFdistY)
    PercValue = CDFdistX(length(CDFdistX));
else
    PercValue = CDFdistX(aux);
end

end 