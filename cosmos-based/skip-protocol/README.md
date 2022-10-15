# skip-protocol

**Versi saat ini**

- **network/chain-id** : `uni-5`
- **version**: `v0.34.21-mev.3`

## Official links

- Website: https://skip.money

## Auto installation

```
wget -O juno.sh https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/cosmos-based/skip-protocol/juno.sh && chmod 777 juno.sh && ./juno.sh
```
## Pasca installasi
```
source $HOME/.bash_profile
```
## Snapshot (Optional)

```
sudo systemctl stop junod

SNAP_RPC="https://juno-testnet-rpc.jambulmerah.dev:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.juno/config/config.toml

junod tendermint unsafe-reset-all --home $HOME/.juno
sudo systemctl restart junod

```

### Cek log

```
journalctl -fu junod -o cat
```

#
