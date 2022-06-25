

# usage: ./iptables_port_block RULES PACKET MARK PORTS
#   RULES - how many rules are we setting up?
#   PACKET - which item is this rule?
#   MARK - what it should be marked with
#   PORTS - what port interval to use
function iptables_port_block(){
RULES=$1
PACKET=$2
MARK=$3
PORTS=$4
  cat << EOF

# ===${PORTS}===

iptables -t nat -A PREROUTING -m statistic --mode nth --every ${NRULES} --packet ${PACKET} -j MARK --set-mark ${MARK}
iptables -t nat -A OUTPUT -m statistic --mode nth --every ${NRULES} --packet ${PACKET} -j MARK --set-mark ${MARK}

iptables -t nat -A POSTROUTING -p icmp -o $TUNNEL_NAME -m mark --mark ${MARK} -j SNAT --to $IP4:${PORTS}
iptables -t nat -A POSTROUTING -p tcp -o $TUNNEL_NAME -m mark --mark ${MARK} -j SNAT --to $IP4:${PORTS}
iptables -t nat -A POSTROUTING -p udp -o $TUNNEL_NAME -m mark --mark ${MARK} -j SNAT --to $IP4:${PORTS}

EOF
}


function iptables_ports_contents(){
  RULE=1
  NRULES=15
  while [ $RULE -le ${NRULES}  ] ; do
    MARK=`expr $RULE + 16`
    PACKET=`expr $RULE - 1`
    PORTL=`expr $RULE \* 4096 + $PSID \* 16`
    PORTR=`expr $PORTL + ${NRULES}`
    PORTS="${PORTL}-${PORTR}"

    iptables_port_block ${NRULES} $PACKET $MARK $PORTS
    RULE=`expr $RULE + 1`
  done
}

function iptables_ports_table_contents() {
  NRULES=`env_ports | wc -l `
  PACKET=0
  env_ports | while read PORTS
  do
    MARK=`expr $PACKET + 17`
    iptables_port_block $NRULES $PACKET $MARK $PORTS
    PACKET=`expr $PACKET + 1`
  done
}


# usage iptables_contents [table]
#   from-table => use the entire table from env.ports
#   no argument => compute 15 tules
function iptables_contents(){
  cat <<EOF
# flush all rulles first
iptables -t nat -F
EOF
  case "$1" in
    from-table)
      iptables_ports_table_contents
      ;;
    *)
      iptables_ports_contents
      ;;
  esac

  cat <<EOF
# route through tunnel
iptables -t mangle -o $TUNNEL_NAME --insert FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1400:65495 -j TCPMSS --clamp-mss-to-pmtu
EOF
}
