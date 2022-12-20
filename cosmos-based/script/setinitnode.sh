# Set nodename
clear
nodename_prompt="What nodename do you prefer...? => "
echo -e "Next, we need to give your "$project_name" node a nickname..."
while true; do
  read -p "$(printf "$nodename_prompt")" nodename
  if [[ $nodename =~ "\"" || $nodename =~ "'" || -z $nodename ]]; then
    echo "Quotes not allowed and input can't be blank"
    nodename_prompt="Please enter new nodename: "
  else
    sleep 1; break
  fi
done

# Set specific port
clear
p2p_port=26656
rpc_port=26657
abci_port=26658
prometheus_port=26660
pprof_port=6060
api_port=1317
grpc_port=9090
grpc_web_port=9091
all_port=("p2p_port" "rpc_port" "abci_port" "prometheus_port" "pprof_port" "api_port" "grpc_port" "grpc_web_port")
tcp_port_regex='^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'
port_type=("P2P listen port" "RPC listen port" "ABCI Application" "PROMETHEUS lport" "PPROF listen port" "API listen port" "gRPC listen port" "gRPC-WEB lport")
invalid_port="Value must be (1-65535) And don't be the same as the others"
bind_ports=("$p2p_port" "$rpc_port" "$abci_port" "$prometheus_port" "$pprof_port" "$api_port" "$grpc_port" "$grpc_web_port")
setPort(){
while true; do
    for (( i=1; i<9; i++ )); do
        read -p "[$i] $(echo -n ${port_type[$i-1]} ${bind_ports[$i-1]}) change to => " ${all_port[$i-1]}
    done
    clear
    echo Checking port is valid...; sleep 1.5
    bind_ports=("$p2p_port" "$rpc_port" "$abci_port" "$prometheus_port" "$pprof_port" "$api_port" "$grpc_port" "$grpc_web_port")
    for (( i=1; i<9; i++ )); do
        if [[ $(echo -n ${bind_ports[@]} | grep -ow "${bind_ports[$i-1]}" | wc -l) -eq 1 && $(echo ${bind_ports[$i-1]}) =~ $tcp_port_regex ]]; then
            echo -e "[$i] ${port_type[$i-1]}:\t( ${bind_ports[$i-1]} )\t✅"
        else
            echo -e "\e[9m[$i] ${port_type[$i-1]}:\t( ${bind_ports[$i-1]} )\t\e[m❌"
            wrong_port=true
        fi
    done
    echo
    if [[ $wrong_port == "true" ]]; then
        wrong_port=false; sleep 1.5;
        echo -e "$invalid_port!..\nPlease change the wrong port with valid port!!..\n"
        sleep 2; continue
    else
       checkPort; break
    fi
done
}

checkPort(){
while true; do
    echo Checking port is available...; sleep 1.5
    bind_ports=("$p2p_port" "$rpc_port" "$abci_port" "$prometheus_port" "$pprof_port" "$api_port" "$grpc_port" "$grpc_web_port")
    for (( i=1; i<9; i++ )); do
        echo -n -e "["$i"] "${port_type[$i-1]}"\t( "${bind_ports[$i-1]}" )"
        ports=$(echo -n ${bind_ports[$i-1]} | sed -e 's/ /,/g')
        if [[ ! $(lsof -i tcp:${ports} | grep -e "(LISTEN)" | awk '{print $9}' | grep -o '[0-9]\+' 2> /dev/null) ]]; then
            echo -e "\t\t✅️"
        else
            echo -e "\t\t❌️ [$i]"
            port_used=true
        fi
    done
    if [[ $port_used == "true" ]]; then
        port_used=false
        echo -e "\nSome port already in use.. Please set a custom port\n$invalid_port\n"
        sleep 1.5; setPort
    else
        break
    fi
done
}

while true; do
    echo "Almost done, set the port to your liking.."
    echo "[1] Use default port"
    echo "[2] Set custom port"
    echo
    echo -n "Input your option => "
    read i
    case $i in
    [1] ) clear; checkPort; break;;
    [2] ) clear; setPort; break;;
    * ) clear;;
    esac
done

# Init node
clear
echo -n -e "Initializing and configuring "$project_name" node..."
sleep 2

# Init testnet
if [[ $join_test == true ]]; then
  $bin_name init "$nodename" --chain-id $testnet_chain_id --home $chain_dir >/dev/null 2>&1
  curl -sSL $testnet_genesis -o $chain_dir/config/genesis.json
  sed -i -e "s/^seeds *=.*/seeds = \"$testnet_seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$testnet_peers\"/" $chain_dir/config/config.toml
  sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$testnet_denom\"/" $chain_dir/config/app.toml
  $bin_name config chain-id $testnet_chain_id --home $chain_dir
  $bin_name config keyring-backend test --home $chain_dir
  if [[ -n $testnet_addrbook ]]; then
    curl -s $testnet_addrbook -o $chain_dir/config/addrbook.json
  fi
# Init mainnet
elif [[ $join_main == true ]]; then
  $bin_name init "$nodename" --chain-id $mainnet_chain_id --home $chain_dir >/dev/null 2>&1
  curl -sSL $mainnet_genesis -o $chain_dir/config/genesis.json
  sed -i -e "s/^seeds *=.*/seeds = \"$mainnet_seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$mainnet_peers\"/" $chain_dir/config/config.toml
  sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$mainnet_denom\"/" $chain_dir/config/app.toml
  $bin_name config chain-id $mainnet_chain_id --home $chain_dir
  $bin_name config keyring-backend test --home $chain_dir
  if [[ -n $mainnet_addrbook ]]; then
    curl -s $mainnet_addrbook -o $chain_dir/config/addrbook.json
  fi
fi

$bin_name config node tcp://localhost:$rpc_port --home $chain_dir
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="500"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $chain_dir/config/app.toml >/dev/null 2>&1
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $chain_dir/config/app.toml >/dev/null 2>&1
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $chain_dir/config/app.toml >/dev/null 2>&1
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $chain_dir/config/app.toml >/dev/null 2>&1
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:$abci_port\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:$rpc_port\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:$pprof_port\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:$p2p_port\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":$prometheus_port\"%" $chain_dir/config/config.toml >/dev/null 2>&1
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:$api_port\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:$grpc_port\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:$grpc_web_port\"%" $chain_dir/config/app.toml >/dev/null 2>&1
$bin_name tendermint unsafe-reset-all --home $chain_dir >/dev/null 2>&1

echo -e "\t✅️"
sleep 2

# Create service with cosmovisor
if [[ $with_cosmovisor == "true" ]]; then

  mkdir -p $chain_dir/cosmovisor/genesis/bin/ >/dev/null 2>&1
  mkdir -p $chain_dir/cosmovisor/upgrades/ >/dev/null 2>&1
  cp $(which $bin_name) $chain_dir/cosmovisor/genesis/bin/ >/dev/null 2>&1

sudo tee /etc/systemd/system/$bin_name.service > /dev/null <<EOF
[Unit]
Description=""$project_name" Service by JambulMerah | Cosmos⚛️Lovers❤️"
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start --home $chain_dir
Restart=always
RestartSec=3
LimitNOFILE=4096

Environment="DAEMON_HOME="$chain_dir""
Environment="DAEMON_NAME="$bin_name""
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Create service without cosmovisor
else

sudo tee /etc/systemd/system/$bin_name.service > /dev/null <<EOF
[Unit]
Description=""$project_name" Service by JambulMerah | Cosmos⚛️Lovers❤️"
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $bin_name) --home $chain_dir start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

fi
