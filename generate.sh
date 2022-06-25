#!/bin/bash
# This is thge main entry point for the script

source env.sh
source lib/sysctl.sh
source lib/networkd.sh
source lib/iptables.sh

case "$1" in
  sysctl)
    sysctl_contents
    ;;
  networkd-wan)
    networkd_wan_contents
    ;;
  networkd-lan)
    networkd_lan_contents
    ;;
  networkd-tunnel-dev)
    networkd_tunnel_dev_contents
    ;;
  networkd-tunnel)
    networkd_tunnel_contents
    ;;
  iptables)
    iptables_contents
    ;;
  *)
    echo please read the README.md file carefully!
    exit 1
    ;;
esac
