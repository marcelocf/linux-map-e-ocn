#!/bin/bash
# This is thge main entry point for the script

source lib/sysctl.sh

case "$1" in
  sysctl)
    source env.sh
    sysctl_contents
    ;;
  systemd)
    source env.sh
    echo systemd
    ;;
  tunnel-forward)
    source env.sh
    echo tunnel-forward
    ;;
  tunnel-ports)
    echo tunnel-ports
    ;;
  *)
    echo please read the README.md file carefully!
    exit 1
    ;;
esac
