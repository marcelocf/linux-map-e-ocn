#!/bin/bash
# contains the methods for generating the networkd configuration.



function networkd_wan_contents(){
  cat << EOF
# /etc/systemd/network/10-wan.network
[Match]
Name=${WAN_IFACE}

[Networks]
Address=${CE}
DNS=2606:4700:4700::1111 
DNS=2606:4700:4700::1001
DNS=2001:4860:4860::8888
DNS=2001:4860:4860::8844

Tunnel=${TUNNEL_NAME}
EOF
}

function networkd_lan_contents() {
  cat << EOF
# /etc/systemd/network/11-lan.network
[Match]
Name=${LAN_IFACE}

[Networks]
Addreess=$LAN_ADDRESS
EOF
}

function networkd_tunnel_dev_contents(){
  cat << EOF
#/etc/systemd/network/${TUNNEL_NAME}.netdev
[NetDev]
Name=${TUNNEL_NAME}
Kind=ip6tnl

[Tunnel]
Mode=ipip6
Local=$CE
Remote=$BR
DiscoverPathMTU=yes
EncapsulationLimit=none
EOF
}

function networkd_tunnel_contents() {
  cat << EOF
[Match]
Name=$TUNNEL_NAME

[Network]
IPForward=ipv4

[Route]
Destination=0.0.0.0/0
EOF
}
