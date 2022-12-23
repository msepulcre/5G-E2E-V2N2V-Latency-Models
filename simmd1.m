function [jumptimes, systsize, systtime] = simmd1(tmax, lambda)
% SIMMD1 simulate a M/D/1 queueing system. Poisson arrivals 
% of intensity lambda, deterministic service times S=1.
% 
% [jumptimes, systsize] = simmd1(tmax, lambda)
%
% Inputs: tmax - simulation interval
%         lambda - arrival intensity 
%
% Outputs: jumptimes - time points of arrivals or departures
%          systsize - system size in M/D/1 queue
%	   systtime - system times
 
% Original authors: R.Gaigalas, I.Kaj
% v1.2 07-Oct-02
% v2: Nov-22 (B.Coll-Perales)



% set default parameter values if ommited
if (nargin==0)
 tmax=1500;
 lambda=0.95;
end

arrtime=-log(rand)/lambda;  % Poisson arrivals
i=1;                  
% -- while (min(arrtime(i,:))<=tmax)
% ++
while i < tmax
    arrtime = [arrtime; arrtime(i, :)-log(rand)/lambda];  
    i=i+1;
end
n=length(arrtime);           % arrival times t_1,...t_n         

arrsubtr=arrtime-(0:n-1)';           % t_k-(k-1)
arrmatrix=arrsubtr*ones(1,n);        
deptime=(1:n)+max(triu(arrmatrix));  % departure times 
                                     % u_k=k+max(t_1,..,t_k-k+1)
				     
B=[ones(n,1) arrtime ; -ones(n,1) deptime']; 
Bsort=sortrows(B,2);                 % sort jumps in order
jumps=Bsort(:,1);
jumptimes=[0;Bsort(:,2)];
systsize=[0;cumsum(jumps)];                 % M/D/1 process
systtime=deptime-arrtime';                  % system times 

% plot a histogram of system times
%figure
%hist(systtime,30);



