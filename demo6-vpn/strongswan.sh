#!/bin/sh


dirty_exit() {
  echo $1 && exit 1
}

[ $(id -u) -eq 0 ] || dirty_exit  "Please re-run as root (e.g. sudo ./path/to/this/script)"

VPNPASSWORD=${VPNPASSWORD:-"supersecret"}
VPNSTARTMODE=${VPNSTARTMODE:-add}
VPNLOCALIP=${VPNLOCALIP:-$(dig +short myip.opendns.com @resolver1.opendns.com)}


[ -z $VPNLOCALPOOL ] && dirty_exit "\$VPNLOCALPOOL must be specified"
[ -z $VPNREMOTEPOOL ] && dirty_exit "\$VPNREMOTEPOOL must be specified"
[ -z $VPNREMOTEIP ] && dirty_exit "\$VPNREMOTEIP must be specified"
[ -z $VPNLOCALIP ] && dirty_exit "\$VPNLOCALIP must be specified"

apt-get update && apt-get install -y strongswan #strongswan-ikev2 libstrongswan-standard-plugins strongswan-libcharon moreutils iptables-persistent

IFACE=$(ip route get 8.8.8.8 | awk -- '{printf $5}')


echo =============================================
echo IFACE         : $IFACE
echo VPNPASSWORD   : $VPNPASSWORD
echo VPNLOCALPOOL  : $VPNLOCALPOOL
echo VPNLOCALIP    : $VPNLOCALIP
echo VPNREMOTEIP   : $VPNREMOTEIP
echo VPNREMOTEPOOL : $VPNREMOTEPOOL
echo =============================================



cat << EOF > /etc/ipsec.secrets
: PSK "$VPNPASSWORD"
EOF

cat << EOF > /etc/ipsec.conf
config setup
    uniqueids=no
    charondebug="cfg 2, dmn 2, ike 2, net 0"

conn  %default
    ikelifetime=3h
    lifetime=1h
    margintime=9m
    keyingtries=%forever
    keyexchange=ikev2
    authby=psk
    mobike=no
    closeaction=restart
    dpdaction=restart
    type=tunnel
    forceencaps=yes

conn k8s-conn
    auto=$VPNSTARTMODE
    left=%any
    leftid=$VPNLOCALIP
    leftsubnet=$VPNLOCALPOOL
    leftallowany=yes
    right=$VPNREMOTEIP
    rightid=$VPNREMOTEIP
    rightsubnet=$VPNREMOTEPOOL
    rightallowany=yes
EOF


for SUBNET in $(echo $VPNLOCALPOOL | tr "," "\n")
do
  sudo iptables -A FORWARD --match policy --pol ipsec --dir in  --proto esp -s $SUBNET -j ACCEPT
  sudo iptables -A FORWARD --match policy --pol ipsec --dir out --proto esp -d $SUBNET -j ACCEPT
  sudo iptables -t nat -A POSTROUTING -s $SUBNET  -o $IFACE -j MASQUERADE
done

sudo systemctl restart strongswan && tail -f /var/log/syslog

