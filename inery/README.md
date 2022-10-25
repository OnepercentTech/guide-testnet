# Inery testnet master node guide installation

## Official Links
- [Official Docs](https://docs.inery.io/)
- [Inery Official Website](https://inery.io/)
- [Inery testnet dashboard](https://testnet.inery.io/dashboard)
- [Inery testnet explorer](https://explorer.inery.io)

## Auto installation 
```
wget -O inery.sh https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/inery/inery.sh && bash inery.sh
```

## (Optional) snapshot or block data
<details>
  <summary>👈Click</summary>
block height `4477701` file size `1.8GB` after extracted `3.9GB` data size folder

- this may take a while

```
cd $HOME/inery-node/inery.setup/master.node
./stop.sh
./clean.sh
wget http:///38.129.16.196/inery-blocks.tar.gz
mv blockchain/data/blockchain/blocks/reversible/shared_memory.bin.bak blockchain/data/blockchain/blocks/reversible/shared_memory.bin
mv blockchain/data/state/shared_memory.bin.bak blockchain/data/state/shared_memory.bin
tar -xzvf inery.tar.gz
./genesis_start.sh
```
- Checklog

```
tail -f $HOME/inery-node/inery.setup/master.node/blockchain/nodine.log
```
</details>

### Post installation
```
source $HOME/.bash_profile
```

### Mendapatkan info block
- Info block tertinggi saat ini
```
curl -sSL -X POST 'http://bis.blockchain-servers.world:8888/v1/chain/get_info' -H 'Accept: application/json' | jq
```
- Info block di local node
```
curl -sSL -X POST 'http://localhost:8888/v1/chain/get_info' -H 'Accept: application/json' | jq
```
### Check your logs
```
tail -f $inerylog | ccze -A
```
- First your master node will start fully synchronizing blocks. you will see like this

![img](./img/sync_true.jpg)

- If the block is fully synced you will see something like this

![img](./img/sync_false.jpg)

## Reg master node as producer block
After the block is fully synced, continue to register as a block producer
- Start master node
command:
```
cd $HOME/inery-node/inery.setup/master.node
./start.sh
```
>NOTE don't do this before the block is fully synced

- Unlock wallet
command:
```
cline wallet unlock -n $IneryAccname --password $(cat $IneryAccname.txt)
```
- Reg producer
```
cline system regproducer $IneryAccname $IneryPubkey 0.0.0.0:9010
```
- Approve as producer
```
cline system makeprod approve $IneryAccname $IneryAccname
```
After the reg producer transaction is successful, now your node starts to get a share of producing blocks
- Check logs again
```
tail -f $inerylog | ccze -A | grep $IneryAccname
```
after a few minutes you will see logs like this

![img](./img/block_produced.jpg)

## Usefull command
