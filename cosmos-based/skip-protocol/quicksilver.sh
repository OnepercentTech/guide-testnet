#!/bin/bash

curl -s https://github.com/jambulmerah/guide-testnet/blob/main/script/logo.sh | bash

sleep 2

# set vars
JUNO_PORT=11
JUNO_CHAIN_ID=uni-5
BINARY_TAG=v10.0.0-alpha.2
PEERS="1e20dbd518660e58c4920b250c86d03b086ac5a6@66.94.108.167:26656,9db06fae1998a14c79cb13d50152828b9fa049e9@195.201.161.122:26656,15c4f14f773079de1301f1f23798ee1e0e94efcb@207.180.241.194:26656,ac9dd6db1d34c15b1de212b0c0c240615bfc2941@207.180.243.215:26656,8228e05a49947039b1ab9f26ac1eac3c96f56031@135.181.223.115:26656,e56b5ce214e628baf7ae315f9af8908306ec7f6e@213.246.39.33:22656,d1463b730c6e0dcea59db726836aeaff13a8119f@3.139.84.144:26656,fd1e3f9baf1922f81bfd9754ddbc4269dbf08264@38.146.3.181:26656,bae287c31f9b23642be7c3c71a9420d6361807b1@95.216.101.38:26656,c478980dee1acc6416874434772eb063acdc6821@135.181.59.162:12656,ed90921d43ede634043d152d7a87e8881fb85e90@65.108.77.106:26709,cfa2ae6075993fa6f97f26c29cde65cb1f214d79@167.86.82.78:16656,e9112600af5786eeab3cf47fd7d97906f33344fd@47.156.153.124:56656,791875d0e15873a98657eac98c6ecace23c5c3b3@194.163.139.3:26656,bfb9b5c06161d3aa798a5ece90912690033ade35@142.132.150.58:26656,5d4c0a8a52f01f1423c5cb14f0e8e576cdc24992@135.181.116.109:16656,abfccd2f0935e07e3c3494f4ca2e6228e5779267@64.5.123.27:26656,f5cfce229f71997d7f4cc766909427ee76a8b4f3@38.146.3.191:26656,bd0c65e90ea582d45a84bf0c7a46b7eac19b3613@88.99.219.120:52656,c96c8e2b31bda1bde94e14dc4cbd483156d72348@194.146.25.205:26656,7f8c7c505a41d0ba2bf9227bfa33a867af3eb001@178.128.173.147:26656,73e936e86ba1198090127c9c461e3274985b6229@94.130.132.227:2073,39b02285db6a2fe87aad8f17c70e68e037bedbde@185.252.235.216:26758,51f9e32a76d738c51dfa353917cef10729b6a600@161.97.118.84:26656,97e836cce2c83e3a1e493429efa317a3fb66b8c4@65.108.79.246:26685,7e2cd43472d830c63b12fa785a7935e8750798c8@65.109.71.119:26656,2e74a7d238cfdd5d03ae0bf0b2f0e50aa88e37d3@44.234.50.242:26656,da407473e7cce06c86ed062267d4f6229a303987@190.3.87.64:26856,62ca9e99a7c9b0957cf6e4d4d745fb9514a56ca9@167.86.81.153:16656,5479526dbdf4f27aa59ddc52be9cf2614049d28e@185.216.178.75:26656,3404c2fc62fcbcb15fe35a5ce59340ec39e41af3@65.109.10.241:26656,f79ce2fab55e56b408d76ddcbc1c82c1a90e315b@54.74.146.114:26656,4a91597dfe3ec715bbf6def225066fbb6ad86cfe@207.180.204.112:36656,db211e8f51ab85615f0fe02f27174dcde61b7418@38.108.68.89:26656"
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

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME

git clone https://github.com/CosmosContracts/juno
cd juno
git fetch
git checkout $BINARY_TAG
sed -i.bak -e '132igithub.com/tendermint/tendermint => github.com/skip-mev/mev-tendermint v0.34.21-mev.3' go.mod
make install

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

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
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
