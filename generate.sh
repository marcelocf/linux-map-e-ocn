#!/bin/bash
# This is thge main entry point for the script

RUNDIR=$(realpath `dirname $0`)

source ${RUNDIR}/env.sh
source lib/networkd.sh
source lib/iptables.sh



function env_ports() {
  cat ${RUNDIR}/env.ports | sed 's/\ /\n/g' | grep '-'
}

case "$1" in
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
  iptables-from-table)
    iptables_contents from-table
    ;;
  *)
    echo please read the README.md file carefully!
    exit 1
    ;;
esac
