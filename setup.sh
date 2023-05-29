#!/usr/bin/env sh

set -e

remove_connection() {
    CUR_CON=$(nmcli -t device | grep "$1")
    CUR_CON=${CUR_CON##*:}

    if [ "$CUR_CON" = "static-$1" ] || [ -n "$CUR_CON" ]; then
        # remove the connection if exists
        nmcli con del "$CUR_CON"
    fi
}

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

# remove previous connection if already exists

if [ 

remove_connection "static-$INTERFACE"
echo "Configuring ssh for Hanwha unit."
echo "Using Static IPv4 address: $STATIC_IP"

nmcli con add con-name "static-$INTERFACE" ifname "$INTERFACE" type ethernet ip4 "$STATIC_IP" gw4 "$GATEWAY"
nmcli con mod "static-$INTERFACE" ipv4.dns "$GATEWAY,$DNS_SERVER"

echo "Removing previous connection(s) and bringing static connection up..."
remove_connection "$INTERFACE"
nmcli con up "static-$INTERFACE" iface "$INTERFACE"

echo "New static connection configured."

if [ -n "$DO_SSH_CONF" ]; then
    echo "Setting up ssh..."

    SSHD=/etc/ssh/sshd_config
    sed -i 's/Port 22/Port '"$SSH_PORT"'/' $SSHD
    sed -i '/Port'"$SSH_PORT"'/s/^#//g' $SSHD # remove '#', if Port conf is disabled

    echo "ssh now on port $SSH_PORT"
    echo "Restarting ssh"
    systemctl restart ssh
fi

exit 0
