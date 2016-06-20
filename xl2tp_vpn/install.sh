if [ `id -u` = 0 ]; then
    echo 'need root privilege'
    exit 1
fi

IP=`hostname -i | head -1 | awk '{print $1}'

pacman -S ufw openswan xl2tpd ppp iptables

cp 99-sysctl.conf /etc/sysctl.d/99-sysctl.conf
sysctl --system

# 
cp chap-secrets /etc/ppp/chap-secrets
sed "s/CLIENT/`openssl rand -base64 5`/;s/SECRET/`openssl rand -base64 10`/" -i /etc/ppp/chap-secrets
chmod 600 /etc/ppp/chap-secrets

# ipsec
cp ipsec.conf /etc/ipsec.conf
sed "s/LEFT/$IP/" -i /etc/ipsec.conf
cp ipsec.secrets /etc/ipsec.secrets
sed "s/IP/$IP/;s/SECRET/`openssl rand -base64 10`/" -i /etc/ipsec.secrets
chmod 600 /etc/ipsec.secrets

cp options.xl2tpd /etc/ppp/options.xl2tpd
cp xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
cp ppp /etc/pam.d/ppp
chmod 644 /etc/pam.d/ppp

# ufw
ufw allow 500/udp
ufw allow 4500/udp
ufw allow 1701
ufw disable && ufw enable

# iptables
iptables -t nat -A POSTROUTING -j SNAT --to-source $IP -o `ifconfig | head -1 | awk -F':' '{print $1}'`

# network
for vpn in /proc/sys/net/ipv4/conf/*; do
  echo 0 > $vpn/accept_redirects;
  echo 0 > $vpn/send_redirects;
done

systemctl enable openswan.service xl2tpd.service 
systemctl restart openswan.service xl2tpd.service 
