#!/bin/bash

curl -s https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/script/logo.sh | bash

sleep 2

# set vars
JUNO_PORT=11
JUNO_CHAIN_ID=uni-5
BINARY_TAG=v11.0.0-alpha
PEERS=`curl -sS https://juno-testnet-rpc.jambulmerah.dev/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | tr "\n" "," | sed 's/.$//'`
node_name_prompt="Masukan nodename "
while true; do
    echo '================================================='
    read -p "$(printf $kuning"$node_name_prompt"$reset)" NODENAME
    echo '================================================='
    if [[ ! "$NODENAME" =~ ^[A-Za-z0-9-]+$ ]]; then
        printf '\nnodename hanya boleh berisi dari huruf besar, kecil, nomor dan tanda sambung -.\n'
        node_name_prompt="Tolong masukan nodename lagi. "
    else
        break
    fi
done

if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$JUNO_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$JUNO_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" &&
sleep 1

# download binary
cd $HOME
git clone https://github.com/CosmosContracts/juno
cd juno
git fetch
git checkout $BINARY_TAG
sed -i.bak -e '132 i \\tgithub.com\/tendermint\/tendermint => github.com\/skip-mev\/mev-tendermint v0.34.21-mev.6' go.mod
go mod tidy
make install
cd $HOME
if [[ $(type junod 2> /dev/null) ]]; then
    mv go/bin/junod $(which junod)
else
    mv go/bin/junod /usr/local/bin
fi
# config
junod config chain-id $JUNO_CHAIN_ID
junod config keyring-backend test
junod config node tcp://localhost:${JUNO_PORT}657

# init
junod init $NODENAME --chain-id $JUNO_CHAIN_ID

# download genesis and addrbook
curl https://raw.githubusercontent.com/CosmosContracts/testnets/main/$JUNO_CHAIN_ID/genesis.json > ~/.juno/config/genesis.json

# set peers and seeds
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.juno/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${JUNO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${JUNO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${JUNO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${JUNO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${JUNO_PORT}660\"%" $HOME/.juno/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${JUNO_PORT}317\"%; s%^address = \":8080\"%address = \":${JUNO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${JUNO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${JUNO_PORT}091\"%" $HOME/.juno/config/app.toml

# config pruningpp
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.juno/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.juno/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.juno/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.juno/config/app.toml

#set minimum gas-
# note testnet denom
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025ujunox\"/" ~/.juno/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.juno/config/config.toml

# reset
junod tendermint unsafe-reset-all --home $HOME/.juno

echo -e "\e[1m\e[32m4. Starting service... \e[0m" &&
sleep 1

# create service
sudo tee /etc/systemd/system/junod.service > /dev/null <<EOF
[Unit]
Description=JUNO
After=network-online.target

[Service]
User=$USER
ExecStart=$(which junod) --home $HOME/.juno start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable junod
sudo systemctl restart junod

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u junod -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${JUNO_PORT}657/status | jq .result.sync_info\e[0m"
