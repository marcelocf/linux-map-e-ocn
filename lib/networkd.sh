#!/bin/bash
# contains the methods for generating the networkd configuration.



function networkd_wan_contents(){
  cat << EOF
# /etc/systemd/network/10-wan.network
[Match]
Name=${WAN_IFACE}

[Network]
# we need to actually connect to build the tunnel....
IPv6AcceptRA=yes

# We can disable IPv4 here, but enabling it allow us to do some clever routing.
# for example, we can use it to expose our LAN services with a dyndns if we want
# since the other IPv4 address they give us is shared
DHCP=yes

DNS=2606:4700:4700::1111 
DNS=2606:4700:4700::1001
DNS=2001:4860:4860::8888
DNS=2001:4860:4860::8844

Tunnel=${TUNNEL_NAME}

[Address]
# but we must also listen to the IP for our CE
Address=${CE}
# this is just in case you are given the same IP as CE by the ISP (not sure
# if it actually happens; it didn't for me)
DuplicateAddressDetection=no


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
# this will automatically setup sysctl for routing here
IPForward=ipv4
BindCarrier=${WAN_IFACE}
DefaultRouteOnDevice=yes
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no

[Route]
Destination=0.0.0.0/0
EOF
}
