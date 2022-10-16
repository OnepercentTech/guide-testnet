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
### Cek versi
```
junod status 2>&1 | jq .NodeInfo
```
> **NOTE**: pastikan **"network"**:`"uni-5"` dan **version**:`"version": "v0.34.21-mev.3"`

### Cek sync info
```
junod status 2>&1 | jq .SyncInfo
```
### Cek log

```
journalctl -fu junod -o cat
```
### buat wallet
```
junod keys add <keyname>
```
Minta faucetnya di discord juno

### buat validator
```
junod tx staking create-validator \
--amount 9000000ujunox \
--commission-max-change-rate "0.1" \
--commission-max-rate "0.20" \
--commission-rate "0.1" \
--min-self-delegation "1" \
--details "validators write bios too" \
--pubkey=$(junod tendermint show-validator) \
--moniker <isi_nama_bebas> \
--gas-prices 0.025ujunox \
--from <key-name>
```
### Tambahkan config `[sidecar]` di `config.toml`
```
[sidecar]
relayer_conn_string = "d1463b730c6e0dcea59db726836aeaff13a8119f@3.139.84.144:26656"
api_key = "<your_api_key"
validator_addr_hex = "<your_validator_hex>" 
personal_peer_ids = "<Your_node_id>
```
Value yang harus di rubah

- 1. **`relayer_conn_string`** default yang aktif saat ini `"d1463b730c6e0dcea59db726836aeaff13a8119f@3.139.84.144:26656"`
- 2. **`api_key`** Minta di tele dev nya DM
- 3. **`validator_addr_hex`** check with
command:
```
junod status 2>&1 | jq -r .ValidatorInfo.address
```
atau command:
```
cat $HOME/.juno/config/priv_validator_key.json | jq -r .address
```
- 4. **`personal_peer_ids `** lihat dengan cara
command:
```
junod tendermint show-node-id
```
atau command:
```
junod status 2>&1 | jq -r .NodeInfo.id
```

```
nano $HOME/.juno/config/config.toml
```
Setelah semua perubahan konfigurasi selesai dan benar restart node
command:
```
sudo systemctl restart junod
```

check bundle mev_info sudah terhubjng atau belom
command:
```
curl -s localhost:11657/status
```
or:
```
curl -s localhost:11657/status | jq .result.mev_info
```
anda akan melihat sesuatu yang seperti ini

`"mev_info": {
   "is_peered_with_relayer": true,
   "last_received_bundle_height": "0"
 }`

 Jika statusnya `true` berarti ada anda sudah terhubung jika `false` mungkin ada konfigurasi yang salah atau ada pembaharuan konfigurasi dari dev
