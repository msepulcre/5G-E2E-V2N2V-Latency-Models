function [lAPP_avg, PDFapp, CDFapp, lambdaV2XAS, YCDF, XCDF, NumProcessors] = ...
    V2XASLatency(Deployment, PktSize, lambdaCore, x_distr,BroadMulticast_Unicast, Ncopies, slot)

%IBM & Vicomtech (H2020 VI-DAS): The role of cloud-computing in the development and application of
%ADAS (https://ieeexplore.ieee.org/document/8553029)
%3072 cores/app  --> 110 cpus of 28 cores
%https://ark.intel.com/content/www/us/en/ark/products/series/204098/3rd-generation-intel-xeon-scalable-processors.html
%Intel® Xeon® Platinum 8380HL Processor	Launched	Q2'20	28	4.30 GHz	2.90 GHz
%MEC system used in reference MEC deployments (see Intel whitepapper: "Case study of Scaled-up SKT* 5G MEC reference architecture"
%https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/case-study-of-scaled-up-skt-5g-mec-reference-architecture.pdf
%MEC system Intel Xeon Gold 6252N processor (https://ark.intel.com/content/www/us/en/ark/products/193951/intel-xeon-gold-6252n-processor-35-75m-cache-2-30-ghz.html)
%Pag. 7 Option i, Name 6252N, CPUs 96 --> 4 processors of 24 cores each
%MEC-BS (see cabinet 600mm): https://www.zte.com.cn/global/products/core_network/201707261051/E5430-G4
%Processor 2 * Intel Xeon Skylake or Cascade Lake extensible processor
%https://www.gigabyte.com/Solutions/Networking/5g-imec-networking-platform
%https://www.gigabyte.com/Edge-Server/H242-Z10-rev-100#ov


lAPP_avg = slot;        % upper bounded
lambda = lambdaCore;    % Ratio of packets arriving to the V2X AS/second
nu_slot = ceil(slot * lambda); %Ratio of packets arriving to the V2X AS/slot
samples = 1000; 
beta = 100 + 200*rand(1, samples); %U(100, 300)
beta_avg = (300 + 100)/2;

F = nu_slot * PktSize * beta_avg / lAPP_avg;

switch Deployment
    case 1  %DataCenter !!!!
        NumProcessors = ceil(F/(4.3e9 * 28 * 2)) ; 
    case {2, 3, 4}  %MECs
        NumProcessors = ceil(F/(3.6e9 * 24 * 2)) ; 
    otherwise
         error(['Incorrect deployment selection (' num2str(Deployment) ')'])
end

lAPP = nu_slot .* PktSize .* beta ./ F ;

X=lAPP;
x = x_distr;

%[YCDF,XCDF] = cdfcalc(lAPP); Not supported any more by Matlab
n = length(X);
X = sort(X(:));
YCDF = (1:n)' / n;
notdup = ([diff(X(:)); 1] > 0);
XCDF = X(notdup);
YCDF = [0; YCDF(notdup)];

[PDFapp,CDFapp] = EstimateDistribution(X,x);

lambdaV2XAS = lambdaCore;
if BroadMulticast_Unicast == 2
    lambdaV2XAS = lambdaCore * Ncopies;
end

end