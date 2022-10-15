#!/bin/bash
clear

curl -sS https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/script/logo.sh | bash

sleep 3

# set vars

echo -e "\e[1;33m1. Updating packages... \e[0m"
sleep 1

# update

sudo apt update && apt upgrade -y
clear

echo -e "\e[1;33m2. Installing dependencies... \e[0m"
sleep 1
# packages
sudo apt install ca-certificates curl gnupg lsb-release software-properties-common -y
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt install python3-dev python3-pip ethereum jq ccze -y
clear
echo -e "\e[1;33m3. Downloading and building binaries... \e[0m"
 sleep 1

# download virtualenv
cd /root
pip3 install -U pip
pip3 install -U virtualenv

# create venv
virtualenv $HOME/.nulink-venv

# activate venv
source $HOME/.nulink-venv/bin/activate

# Download nulink
wget https://filetransfer.nulink.org/release/nulink-0.1.0-py3-none-any.whl
pip3 install nulink-0.1.0-py3-none-any.whl

# Verify installaation
source $HOME/.nulink-venv/bin/activate
python -c "import nulink"
echo 'source $HOME/.nulink-venv/bin/activate' >> $HOME/.nulink_profile
source $HOME/.nulink_profile

# Create worker node account

sleep 1
clear
echo -e "\n\e[1;33m4. Set keystore password as env vars...\e[0m\n"

unset NULINK_OPERATOR_ETH_PASSWORD NULINK_KEYSTORE_PASSWORD PASSWORD
read -p "Enter your password min 8 characters: " PASSWORD
echo "export NULINK_KEYSTORE_PASSWORD=$PASSWORD" >> $HOME/.nulink_profile
echo "export NULINK_OPERATOR_ETH_PASSWORD=$PASSWORD" >> $HOME/.nulink_profile
echo -e "\e[1m"

echo '================================================='
echo -e "Your keystore password: \e[1;33m$PASSWORD\e[0;1m Please save and remember your password\e[0m"
echo '================================================='
sleep 1

echo -e "\n\e[1;33m5. Create worker node account. Copy your keystore password and paste below\e[0m\n"

KEYSTORE="$HOME/.nulink"
OLD_KEYSTORE="$HOME/.nulink-old"
if [[ -d $KEYSTORE && -d $OLD_KEYSTORE ]]; then
    mv $KEYSTORE/* $OLD_KEYSTORE/
    geth account new --keystore $KEYSTORE
elif [[ -d $KEYSTORE ]];then
    mkdir -p $OLD_KEYSTORE
    mv $KEYSTORE/* $OLD_KEYSTORE/
    geth account new --keystore $KEYSTORE
else
    geth account new --keystore $KEYSTORE
fi
# Create ursula configuration

echo -e "\e[1;33m6. Init config nulink ursula. \n\nCopy the\e[0m \e[0;4;36mseed phrase\e[0m, \e[1;33mtype \e[1;7;4;36my\e[0;1;33m and press enter. then paste the seed phrase and press enter\e[0m\n"

OPERATOR_ADDRESS=$(cat $HOME/.nulink/* | jq -r '.address')
NULINK_IP=$(curl -s ifconfig.me)

nulink ursula init \
--signer keystore://$HOME/.nulink/ \
--eth-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
--network horus \
--payment-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
--payment-network bsc_testnet \
--operator-address $OPERATOR_ADDRESS \
--max-gas-price 2000 \
--rest-host $NULINK_IP \
--rest-port 9151

# Create systemd
sudo tee /etc/systemd/system/nulinkd.service > /dev/null <<EOF
[Unit]
Description=nulink daemon
After=network.target

[Service]
User=root
Type=simple
ExecStart=/bin/bash -c 'source $HOME/.nulink-venv/bin/activate; exec nulink ursula run --no-block-until-ready'
Restart=on-failure
LimitNOFILE=65535

Environment="NULINK_KEYSTORE_PASSWORD=$PASSWORD"
Environment="NULINK_OPERATOR_ETH_PASSWORD=$PASSWORD"

[Install]
WantedBy=multi-user.target
EOF

# enable systemd
sudo systemctl daemon-reload
sudo systemctl enable nulinkd
systemctl restart nulinkd

# Enable firewall
echo -e '\e[1;33m7.Enable firewall allow incoming port 9151...\n\e[0m'
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 9151
ufw limit ssh
ufw enable

echo -e '\n\e[1;33m=============== SETUP FINISHED ===================\n\e[0m'
echo -e "\e[1mYour node uri\e[1;33m $NULINK_IP:9151\e[0m"
echo -e "\e[1mYour operator address \e[1;33m$OPERATOR_ADDRESS\e[0m\n"
echo -e "\e[1mNow bond your worker and fill the operator address and node uri in staking dapp \e[1;33mhttps://test-staking.nulink.org/\n"
echo -e "\e[1mCheck your logs \e[1;32m journalctl -ocat -funulinkd | ccze -A\e[0m\n"
