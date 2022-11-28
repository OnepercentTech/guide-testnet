#!/bin/bash
clear
echo -e "\e[96m"
##########################################################
#     START configuration by https://jambulmerah.dev     #
##########################################################
# Project name
project_name="Neutron"
repo="https://github.com/neutron-org/neutron.git"
repo_dir="neutron"
chain_dir="$HOME/.neutrond"
bin_name="neutrond"

# Testnet
testnet_denom="untrn"
testnet_chain_id="quark-1"
testnet_repo_tag="v0.1.1"
testnet_statesync_rpc="https://neutron-testnet-rpc.jambulmerah.dev:443"
testnet_genesis="https://raw.githubusercontent.com/neutron-org/testnets/main/quark/genesis.json"
testnet_seeds="c89b8316f006075ad6ae37349220dd56796b92fa@tenderseed.ccvalidators.com:29001"
testnet_peers=`curl -sS $testnet_statesync_rpc/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's/\n/,/g;s/.$//'`
testnet_snapshot=`curl -s https://snapshots3-testnet.nodejumper.io/neutron-testnet/ | egrep -o ">quark-1.*\.tar.lz4" | tr -d ">"`
testnet_snapshot_url="https://snapshots3-testnet.nodejumper.io/neutron-testnet/${testnet_snapshot}"
testnet_snapshot_provider="Nodejumper.io"

# Mainnet
mainnet_denom="untrn"
mainnet_chain_id="SOON"
mainnet_repo_tag="v0.1.1"
mainnet_statesync_rpc="https://neutron-testnet-rpc.jambulmerah.dev:443"
mainnet_genesis=""
mainnet_seeds=""
mainnet_peers=""
mainnet_snapshot=(`curl -s https://snapshots3-testnet.nodejumper.io/neutron-testnet/ | grep -o ">quark-1.*\.tar.lz4" | tr -d ">"`)
mainnet_snapshot_url="https://snapshots3-testnet.nodejumper.io/neutron-testnet/${testnet_snapshot}"
mainnet_snapshot_provider="Nodejumper.io"

# Script
bline="================================================================="
build_binary="https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/cosmos-based/script/buildbinary.sh"
set_init_node="https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/cosmos-based/script/setinitnode.sh"
sync_method="https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/cosmos-based/script/syncmethod.sh"
##########################################################
#      END configuration by https://jambulmerah.dev      #
##########################################################


while true; do
if [[ -d $chain_dir ]]; then
  echo "Aborting: $project_nect chain directory in $chain_dir exists"
  exit 1
fi
cosmovisorOpt(){
echo "[1] Run with cosmovisor..."
echo "[2] Run without cosmovisor..."
echo "[3] Back"
echo "[0] Exit"
echo -n "What do you like...? "
}
  curl -s https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/script/logo.sh | bash
  echo $bline
  echo "Welcome to "$project_name" node installer by jambulmerah | Cosmos⚛️Lovers❤️"
  echo $bline
  echo
  echo "[1] Install "$project_name" mainnet node("$mainnet_chain_id")"
  echo "[2] Install "$project_name" testnet node ("$testnet_chain_id")"
  echo "[0] Exit"
  read -p "What chain do you want to run? " opt
  if [[ ! $opt == [0-2] ]]; then
    continue
  elif [[ $opt == "0" ]]; then
    exit
  elif [[ $opt -eq 1 ]]; then
    clear
    echo -e ""$project_name" for mainnet will be available soon"
    sleep 3
mainnetSoon(){
    while true; do
      clear
      echo "Choose your service to run node "$project_name" "$testnet_chain_id""
      cosmovisorOpt
      read i
      if [[ ! $i == [0-3] ]]; then
	continue
      elif [[ $i == "0" ]]; then
        exit
      elif [[ $i -eq 1 ]]; then
        join_test=true
	with_cosmovisor=true
        break
      elif [[ $i -eq 2 ]]; then
        join_main=true
        break
      elif [[ $i -eq 3 ]]; then
        break
      fi
    done
}
  elif [[ $opt -eq 2 ]]; then
    while true; do
      clear
      echo "Choose your service to run node "$project_name" "$testnet_chain_id""
      cosmovisorOpt
      read i
      if [[ ! $i == [0-3] ]]; then
	continue
      elif [[ $i == "0" ]]; then
        exit
      elif [[ $i -eq 1 ]]; then
        join_test=true
	with_cosmovisor=true
        break
      elif [[ $i -eq 2 ]]; then
        join_test=true
        break
      elif [[ $i -eq 3 ]]; then
        break
      fi
    done
  fi
  if [[ $join_test == "true" || $join_main == "true" ]]; then
    clear
    . <(curl -sSL "$build_binary")
    clear
    . <(curl -sSL "$set_init_node")
    clear
    . <(curl -sSL "$sync_method")
    clear
    sleep
    break
  fi
done
clear
echo -e '=============== $project_name node setup finished ==================='
echo -e "To check logs: \tjournalctl -u $bin_name -f -o cat"
echo -e "To check sync status: \tcurl -s localhost:${rpc_port}/status | jq .result.sync_info\e[m"

