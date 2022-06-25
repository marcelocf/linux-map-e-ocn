#!/bin/bash
# generates the sysctl file



function sysctl_contents(){
  cat <<EOF
# enable IPv4 packet forward
net.ipv4.ip_forward=1
# disable IPv6 in LAN for simplicity
net.ipv6.conf.${LAN_IFACE}.disable_ipv6=1
EOF
}
