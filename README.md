# Network Infrastructure - scotynau.tech & hyperlab.es

Este repositorio documenta la arquitectura de red híbrida (GCP + Multi-site) que interconecta los servicios de scotynau.tech y hyperlab.es.

## Topología de Red

A continuación se muestra el diagrama de la infraestructura utilizando Mermaid.js.

```mermaid
graph TD
    %% Definición de Estilos (Fancy Mode)
    classDef cloud fill:#0d47a1,stroke:#448aff,stroke-width:2px,color:#fff,rx:10,ry:10
    classDef internal fill:#e65100,stroke:#ff9800,stroke-width:2px,color:#fff,rx:5,ry:5
    classDef ricardo fill:#004d40,stroke:#1de9b6,stroke-width:2px,color:#fff,rx:5,ry:5
    classDef mgmt fill:#4a148c,stroke:#7c4dff,stroke-width:2px,color:#fff,rx:20,ry:20
    classDef service fill:#263238,stroke:#eceff1,stroke-width:1px,color:#fff,font-style:italic

    subgraph External_Services [🌐 Servicios Externos]
        M365[Microsoft 365 - Correo scotynau.tech]:::service
    end

    subgraph GCP_Cloud [☁️ Google Cloud Platform]
        Bastion[<b>Bastion Server</b><br/>10.0.0.1]:::cloud
        WG_Srv[Wireguard Server]:::cloud
        Nginx[Nginx Reverse Proxy]:::cloud
        Velocity[Velocity Minecraft Proxy]:::cloud
    end

    subgraph Management [🛡️ Gestión]
        MgmtPC[💻 PC de Gestión<br/>10.0.0.4]:::mgmt
    end

    subgraph Scotynau_Net [🏗️ scotynau.tech]
        MT_CRS[<b>MikroTik CRS418</b><br/>10.0.0.2]:::internal
        DMZ[DMZ<br/>192.168.2.0/24]:::internal
        LAN[LAN<br/>192.168.1.0/25]:::internal
        WiFi[WiFi<br/>192.168.1.128/25]:::internal
    end

    subgraph Hyperlab_Net [🔬 hyperlab.es]
        Flint2[<b>OpenWRT Flint 2</b><br/>10.0.0.3]:::ricardo
        MT_Ric[MikroTik CRS326]:::ricardo
        RLAN[LAN<br/>192.168.10.0/24]:::ricardo
        RWiFi[WiFi<br/>192.168.20.0/24]:::ricardo
        RDMZ[DMZ<br/>192.168.30.0/24]:::ricardo
    end

    %% Túneles VPN con estilo
    Bastion <== "Wireguard Tunnel" ==> MT_CRS
    Bastion <== "Wireguard Tunnel" ==> Flint2
    Bastion <== "Wireguard Tunnel" ==> MgmtPC

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
