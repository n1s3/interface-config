#!/usr/bin/env sh

set -e

if [ $(id -u) -ne 0 ]; then
    echo "Root privledges are required."
    echo "You must run this script as root."
    exit 1
fi

INTERFACE="eth1"
SSH_PORT=23
# specify in cidr notation
STATIC_IP="192.168.20.10/24"
# default gw is X.X.X.1
GATEWAY=${STATIC_IP%.*}.1
DNS_SERVER="1.1.1.1"

# parse args
while [ $# -gt 0 ]; do
    case "$1" in
        --interface | -i) INTERFACE="$2"; shift;;
        --ssh | -S) DO_SSH_CONF="true";;
        --port | -p) SSH_PORT="$2"; shift;;
        --addr | -I) STATIC_IP="$2"; shift;;
        --gateway | -g) GATEWAY="$2"; shift;;
        --dns | -d) DNS_SERVER="$2"; shift;;
        *) break
    esac
shift
done

echo "Configuring ssh for Hanwha unit."
echo "Using Static IPv4 address: $STATIC_IP"

nmcli con add con-name "static-$INTERFACE" ifname "$INTERFACE" type ethernet ip4 "$STATIC_IP" gw4 "$GATEWAY"
nmcli con mod "static-$INTERFACE" ipv4.dns "$GATEWAY,$DNS_SERVER"

echo "Remove previous connection and bringing static connection up..."
CUR_CON=$(nmcli con show | grep "$INTERFACE")
CUR_CON=${CUR_CON##*:}

nmcli con del "$CUR_CON"
nmcli con up "static-$INTERFACE" iface "$INTERFACE"

echo "New static connection configured."

if [ -z "$DO_SSH_CONF" ]; then
    echo "Setting up ssh..."

    SSHD=/etc/ssh/sshd_config
    sed -i 's/Port 22/Port '"$SSH_PORT"'/' $SSHD
    sed -i '/Port'"$SSH_PORT"'/s/^#//g' $SSHD # remove '#', if Port conf is disabled

    echo "ssh now on port $SSH_PORT"
    echo "Restarting ssh"
    systemctl restart ssh
fi

exit 0
