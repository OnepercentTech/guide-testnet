# Via statesync

viaStatesync(){
while true; do
# Testnet statesync
if [[ $join_test == "true" ]]; then
LATEST_HEIGHT=$(curl -s $testnet_statesync_rpc/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$testnet_statesync_rpc/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
  if [[ ("$BLOCK_HEIGHT" != "") && ("$TRUST_HASH" != "") ]]; then
    sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
    s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$testnet_statesync_rpc,$testnet_statesync_rpc\"| ; \
    s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
    s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $chain_dir/config/config.toml
    sed -i -E "s|snapshot-interval = .*|snapshot-interval = 2000|g" $chain_dir/config/app.toml
    sed -i -E "s|snapshot-keep-recent = .*|snapshot-keep-recent = 5|g" $chain_dir/config/app.toml
    break
  else
    clear
    read -p "Hmm, failed to fetch state sync params. Trying again...?(Y/n)" retry
    if [[ $retry == [Nn] ]]; then
      break
    fi
  fi

elif [[ $join_main == "true" ]]; then

# Mainnet state sync
LATEST_HEIGHT=$(curl -s $mainnet_statesync_rpc/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$mainnet_statesync_rpc/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
  if [[ ("$BLOCK_HEIGHT" != "") && ("$TRUST_HASH" != "") ]]; then
    sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
    s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$mainnet_statesync_rpc,$testnet_statesync_rpc\"| ; \
    s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
    s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $chain_dir/config/config.toml
    sed -i -E "s|snapshot-interval = .*|snapshot-interval = 2000|g" $chain_dir/config/app.toml
    sed -i -E "s|snapshot-keep-recent = .*|snapshot-keep-recent = 5|g" $chain_dir/config/app.toml
    break
  else
    clear
    read -p "\nHmm, failed to fetch state sync params. Trying again...?(Y/n)" retry
    if [[ $retry == [Nn] ]]; then
      break
    fi
  fi
fi
done
}

# Via snapshot
viaSnapshot(){
clear
if [[ $join_test == "true" ]]; then
  if [[ $testnet_snapshot != "" ]]; then
    rm -rf $chain_dir/data
    curl $testnet_snapshot_url | lz4 -dc - | tar -xf - -C $chain_dir
  else
    echo -e "Hmm, failed to fetch snapshot url..."; sleep 3
  fi
elif [[ $join_main == "true" ]]; then
  if [[ $mainnet_snapshot != "" ]]; then
    rm -rf $chain_dir/data
    curl $mainnet_snapshot_url | lz4 -dc - | tar -xf - -C $chain_dir
  else
    echo -e "Hmm, failed to fetch snapshot url..."; sleep 3
  fi
fi
}

# Without snapshot and state sync
startService(){
sudo systemctl daemon-reload >/dev/null 2>&1
sudo systemctl enable $bin_name >/dev/null 2>&1
sudo systemctl restart $bin_name >/dev/null 2>&1
}

while true; do
  clear
  echo "Finally, choose your preferred block synchronization method"
  if [[ $join_test == "true" ]]; then
    echo "[1] Sync "$project_name" "$testnet_chain_id" with snapshot provided by "$testnet_snapshot_provider""

  elif [[ $join_main == "true" ]]; then
    echo "[1] Sync "$project_name" "$mainnet_chain_id" with snapshot provided by "$mainnet_snapshot_provider""
  fi

echo "[2] Sync "$project_name" with statesync"
echo "[3] Sync "$project_name" blocks from scratch without snapshot and statesync"
read -p "What do you like...? " sync

if [[ ! $sync == [1-3] ]]; then
  clear; continue
elif [[ $sync -eq 1 ]]; then
  viaSnapshot; startService; break
elif [[ $sync -eq 2 ]]; then
  viaStatesync; startService; break
elif [[ $sync -eq 3 ]]; then
  startService; break
fi
done