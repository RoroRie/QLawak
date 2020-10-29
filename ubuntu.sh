#!/usr/bin/env bash
#
# Personal Ubuntu setup for QLauncher
#
# Original https://github.com/Xavier099/qqq-setup
#

DIRQL="$HOME/qlauncher"
QLS="$DIRQL/qlauncher.sh"
QLPKG="app.tar.gz"
DKR="get-docker.sh"

function echo () {
    command echo -e "${@}"
}

echo "Install needed package"
sudo apt update
sudo apt install \
         curl \
         net-tools \
         qrencode \
         wget -y

echo
echo "docker"
curl -fsSL https://get.docker.com -o ${DKR}
sh ${DKR}
echo

# Setup port
yes | sudo ufw enable
echo "QLauncher need port 433, 32440, 32443, 32446 to be open"
sudo ufw allow 32440/tcp
sudo ufw allow 32441/tcp
sudo ufw allow 32442/tcp
sudo ufw allow 32443/tcp
sudo ufw allow 32444/tcp
sudo ufw allow 32445/tcp
sudo ufw allow 32446/tcp
sudo ufw allow 32447/tcp
sudo ufw allow 32448/tcp
sudo ufw allow 32449/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
# allow ipfs, v2ray and others
sudo ufw allow 2376/tcp
sudo ufw allow 2377/tcp
sudo ufw allow 7946/tcp
sudo ufw allow 7946/udp
sudo ufw allow 4789/udp
sudo ufw allow 8080/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 4001/tcp
sudo ufw allow 9096/tcp

# download QLauncher
echo "Create dir QLauncher"
mkdir "${DIRQL}"
echo "Downloading ..."
wget https://github.com/poseidon-network/qlauncher-linux/releases/latest/download/ql-linux.tar.gz -O "${QLPKG}"
echo "Extracting QLauncher"
tar -vxzf "${QLPKG}" -C "${DIRQL}"
rm "${QLPKG}"
echo "Done."
echo

# automatically run QLauncher
echo "run QLauncher on system startup"
cat > /etc/systemd/system/qlauncher.service << EOF
[Unit]
Description=qlauncher.service
[Service]
Type=simple
ExecStart=$QLS start
ExecStop=$QLS stop
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
echo
systemctl daemon-reload
systemctl enable qlauncher
echo "done."
echo

echo
echo "run ql -h or ql --help"
echo

# last step
curl -fsSL https://raw.githubusercontent.com/RoroRie/ql/main/ql  -o /usr/bin/ql
chmod +x /usr/bin/ql

# cleanup
rm ${DKR}
rm ubuntu.sh
