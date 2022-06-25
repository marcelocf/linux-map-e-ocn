#!/bin/bash
# This is thge main entry point for the script

source lib/sysctl.sh

case "$1" in
  sysctl)
    source env.sh
    sysctl_contents
    ;;
  systemd-wan)
    source env.sh
    echo systemd
    ;;
  systemd-lan)
    source env.sh
    echo systemd
    ;;
  systemd-tunnel)
    source env.sh
    echo systemd
    ;;
  iptables)
    source env.sh
    echo tunnel-forward
    ;;
  iptables-ports)
    echo tunnel-ports
    ;;
  *)
    echo please read the README.md file carefully!
    exit 1
    ;;
esac
