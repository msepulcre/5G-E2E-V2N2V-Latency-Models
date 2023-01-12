# 5G E2E V2N2V Latency Models

This code implements in Matlab the analytical latency models of the 5G Vehicle-to-Network-to-Vehicle (V2N2V) communications presented in:

> B. Coll-Perales, M.C. Lucas-Estañ, T. Shimizu, J. Gozalvez, T. Higuchi, S. Avedisov, O. Altintas, and M. Sepulcre, "End-to-End V2X Latency Modeling and Analysis in 5G Networks," in IEEE Transactions on Vehicular Technology, doi: 10.1109/TVT.2022.3224614.
 
Final version available at: https://ieeexplore.ieee.org/document/9964110

Post-print version available at: https://arxiv.org/abs/2201.06082

In order to comply with our sponsor guidelines, we would appreciate if any publication using this code references the above-mentioned publication.

## Abstract:

> 5G networks provide higher flexibility and improved performance compared to previous cellular technologies. This has raised expectations on the possibility to support  advanced Vehicle to Everything (V2X) services using the cellular network via Vehicle-to-Network (V2N) and Vehicle-to-Network-to-Vehicle (V2N2V) connections. The possibility  to support critical V2X services using 5G V2N2V or V2N connections depends on their end-to-end (E2E) latency. The E2E latency of V2N2V or V2N connections depends on the  particular 5G network deployment, dimensioning and configuration, in addition to the  network load. To date, few studies have analyzed the capabilities of V2N2V or V2N connections to support critical V2X services, and most of them focus on the 5G radio  access network or consider dedicated 5G pilot deployments under controlled conditions.  This paper progresses the state-of-the-art by introducing a novel E2E latency model to quantify the latency of 5G V2N and V2N2V communications. The model includes the latency introduced at the radio, transport, core, Internet, peering points and application server (AS) when vehicles are supported by a single mobile network operator (MNO) and when they are supported by multiple MNOs. The model can quantify the latency experienced when the V2X AS is deployed from the edge of the network (using MEC platforms) to the cloud. Using this model, this study estimates the E2E latency of 5G V2N2V connections for a large variety of possible 5G network deployments and configurations. The analysis helps identify which 5G network deployments and configurations are more suitable to meet V2X latency requirements. To this aim, we consider as case study the cooperative lane change service. The conducted analysis highlights the challenge for centralized network deployments that locate the V2X AS at the cloud to meet the latency requirements of advanced V2X services. Locating the V2X AS closer to the cell edge reduces the latency. However, it requires a higher number of ASs and also a careful dimensioning of the network and its configuration to ensure sufficient network and AS resources are dedicated to serve the V2X traffic.

## Models 

main.m is the main script you have to run to get the end-to-end latency $l_{E2E}$ experienced in 5G V2N2V communications as:

### Single-MNO

> $l_{E2E} = l_{radio} + l_{TN} + l_{CN} + l_{UPF-AS} + l_{AS}$

### Multi-MNO

> $l_{E2E} = l_{radio} + l_{TN} + l_{CN} + l_{UPF-AS} + l_{AS} + l_{pp}$

where:
* $l_{radio}$: latency of packets in the radio
* $l_{TN}$: latency of packets in the transport network
* $l_{CN}$: latency of packets in the core network
* $l_{UPF-AS}$: latency of packets in the communication link between the PSA UPF of the CN and the V2X AS (or Internet latency)
* $l_{AS}$: latency introduced by the V2X Application Server
* $l_{pp}$: latency experienced in the peering point between MNOs 


### Supported 5G Network Deployment 
The $l_{E2E}$ can be computed for the following 5G network deployments:
*	Centralized: This deployment considers that the V2X AS is located at the cloud outside the mobile network domain 

![image](https://user-images.githubusercontent.com/83281466/209205958-6164bf65-31ee-45f8-80ea-f4868949b868.png)

* MEC@CN: The MEC is deployed at the CN and hosts the V2X AS

![image](https://user-images.githubusercontent.com/83281466/209205867-0b89c1d0-6a10-4114-8287-5e31f57a7f70.png)

* MEC@M1: The MEC is collocated with the multiplexing node M1

![image](https://user-images.githubusercontent.com/83281466/209205779-a76a6190-2818-4f9e-b9a2-f8f9101cee0c.png)

* MEC@gNB: This deployment considers that the MEC and the local UPF are collocated at the gNB

![image](https://user-images.githubusercontent.com/83281466/209205669-eafca312-ba26-48ab-aa46-60970b3cc2e7.png)


## Contact 
Feel free to contact the corresponding authors Dr. Baldomero Coll-Perales (bcoll@umh.es) if you have any question on the evolution of these models.

## Licence 
This code is licenced under the GNU GPLv2 license.
