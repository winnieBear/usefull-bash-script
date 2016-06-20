cat << EOF | sudo tee /etc/ssh/sshd_config
Protocol 2
Port 22
AddressFamily inet
PermitRootLogin no
StrictModes yes
MaxAuthTries 3
MaxSessions 3
PubkeyAuthentication yes
AuthorizedKeysFile  .ssh/authorized_keys
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
PrintMotd no # pam does that
UsePrivilegeSeparation sandbox      # Default for new installations.
ClientAliveInterval 600
ClientAliveCountMax 0
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 30s
Subsystem   sftp    /usr/lib/ssh/sftp-server
EOF

sudo chmod 600 /etc/ssh/sshd_config
sudo systemctl restart sshd.service
