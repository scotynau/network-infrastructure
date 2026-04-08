# Network Infrastructure - scotynau.tech & hyperlab.es

Este repositorio documenta la arquitectura de red híbrida (GCP + Multi-site) que interconecta los servicios de scotynau.tech y hyperlab.es.

## Topología de Red

A continuación se muestra el diagrama de la infraestructura utilizando Mermaid.js.

```mermaid
graph TD
    subgraph External_Services [Servicios Externos]
        M365[Microsoft 365 - Correo scotynau.tech]
    end

    subgraph GCP_Cloud [Google Cloud Platform]
        Bastion[Bastion Server - 10.0.0.1]
        WG_Srv[Wireguard Server]
        Nginx[Nginx Proxy - scotynau.tech / hyperlab.es]
        Velocity[Velocity Minecraft Proxy]
    end

    subgraph Management [Gestión]
        MgmtPC[PC de Gestión - 10.0.0.4]
    end

    subgraph Scotynau_Net [scotynau.tech]
        MT_CRS[MikroTik CRS418 - 10.0.0.2]
        DMZ[DMZ - 192.168.2.0/24]
        LAN[LAN - 192.168.1.0/25]
        WiFi[WiFi - 192.168.1.128/25]
    end

    subgraph Hyperlab_Net [hyperlab.es]
        Flint2[OpenWRT Flint 2 - 10.0.0.3]
        MT_Ric[MikroTik CRS326]
        RLAN[LAN - 192.168.10.0/24]
        RWiFi[WiFi - 192.168.20.0/24]
        RDMZ[DMZ - 192.168.30.0/24]
    end

    %% Túneles VPN
    Bastion <==>|Wireguard Tunnel| MT_CRS
    Bastion <==>|Wireguard Tunnel| Flint2
    Bastion <==>|Wireguard Tunnel| MgmtPC

    %% Conexiones internas
    MT_CRS --- DMZ
    MT_CRS --- LAN
    MT_CRS --- WiFi
    MT_CRS -.->|MX Records| M365
    
    Flint2 --- MT_Ric
    MT_Ric --- RLAN
    MT_Ric --- RWiFi
    MT_Ric --- RDMZ
```

## Detalles de Segmentación

### scotynau.tech (MikroTik CRS418)
- **Túnel VPN:** 10.0.0.2 (Wireguard)
- **DMZ:** 192.168.2.0/24
- **LAN:** 192.168.1.0/25
- **WiFi:** 192.168.1.128/25
- **Correo:** Microsoft 365 (Business Standard/Basic)

### hyperlab.es (OpenWRT)
- **Túnel VPN:** 10.0.0.3 (Wireguard)
- **LAN:** 192.168.10.0/24
- **WiFi:** 192.168.20.0/24
- **DMZ:** 192.168.30.0/24

### Gestión
- **Admin PC:** 10.0.0.4 (Túnel directo Wireguard)
