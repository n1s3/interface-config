#!/usr/bin/env sh

set -e

remove_connection() {
    CUR_CON=$(nmcli -t device | grep "$1")
    CUR_CON=${CUR_CON##*:}

    if [ -n "$CUR_CON" ]; then
        # remove the connection if exists
        sudo nmcli con del "$CUR_CON"
    fi
}

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

sudo nmcli con add con-name "static-$INTERFACE" ifname "$INTERFACE" type ethernet ip4 "$STATIC_IP" gw4 "$GATEWAY"
sudo nmcli con mod "static-$INTERFACE" ipv4.dns "$GATEWAY,$DNS_SERVER"

echo "New static connection configured."

if [ -n "$DO_SSH_CONF" ]; then
    echo "Setting up ssh..."

    SSHD=/etc/ssh/sshd_config
    sudo sed -i 's/Port 22/Port '"$SSH_PORT"'/' $SSHD
    sudo sed -i '/Port '"$SSH_PORT"'/s/^#//g' $SSHD # remove '#', if Port conf is disabled

    echo "ssh now on port $SSH_PORT"
fi

echo "Restarting ssh, Removing previous connection and bringing static connection up..."
echo -e "\033[31;1mWARNING\033[0m You may immediately lose connection to host!"
echo "ping $STATIC_IP to verify interface is UP and that process has completed succesfully."
echo "Goodbye"

remove_connection "$INTERFACE"
sudo nmcli con up "static-$INTERFACE" iface "$INTERFACE"
sudo systemctl restart ssh

exit 0
