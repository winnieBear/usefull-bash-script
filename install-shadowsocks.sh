cat << EOF | sudo tee /etc/shadowsocks/config.json
{
    "server":"`hostname -i | head -1 | awk '{print $1}'`",
    "server_port":8888,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"`openssl rand -base64 10`",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 5
}
EOF

sudo systemctl enable shadowsocks-server@config.service
sudo systemctl restart shadowsocks-server@config.service
