

function iptables_port_block(){
PACKET=$1
MARK=$2
PORTS=$3
  cat << EOF
iptables -t nat -A PREROUTING -m statistic --mode nth --every 15 --packet ${PACKET} -j MARK --set-mark ${MARK}
iptables -t nat -A OUTPUT -m statistic --mode nth --every 15 --packet ${PACKET} -j MARK --set-mark ${MARK}

iptables -t nat -A POSTROUTING -p icmp -o $TUNNEL_NAME -m mark --mark ${MARK} -j SNAT --to $IP4:${PORTS}
iptables -t nat -A POSTROUTING -p tcp -o $TUNNEL_NAME -m mark --mark ${MARK} -j SNAT --to $IP4:${PORTS}
iptables -t nat -A POSTROUTING -p udp -o $TUNNEL_NAME -m mark --mark ${MARK} -j SNAT --to $IP4:${PORTS}
EOF
}


function iptables_contents(){

  RULE=1
  while [ $RULE -le 15  ] ; do
    MARK=`expr $RULE + 16`
    PACKET=`expr $RULE - 1`
    PORTL=`expr $RULE \* 4096 + $PSID \* 16`
    PORTR=`expr $PORTL + 15`
    PORTS="${PORTL}-${PORTR}"

    echo "# ===${PORTS}==="
    iptables_port_block $PACKET $MARK $PORTS
    RULE=`expr $RULE + 1`
  done


}



