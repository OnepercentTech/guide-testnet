# Nulink testnet local node installatian (without docker)

<p align="center">
 <img height="250" height="auto" src="https://user-images.githubusercontent.com/107190154/190568136-14f5a7d8-5b15-46fb-8132-4d38a0779171.gif">
</p>

## Official Links
- [Official Document](https://docs.nulink.org/products/testnet)
- [Nulink Official Website](https://www.nulink.org/)
- [Nulink Official Telegram](https://t.me/NuLinkChannel)
- [Nulink Discord](https://discord.gg/psSzseWp)

## Minimum Requirements 
- 2-4vCPU
- 4GB of Ram
- 30GB SSD

## One click installation
Before you must login as root
```
sudo -i
chmod -R 700 /root
```
Next
```
wget https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/nulink/nulink.sh && chmod 777 nulink.sh && ./nulink.sh
```
Don't forget to save your mnemonic nulink keystore
### Copy and backup your operator keystore in `/root/.nulink/UTC*`
command:
```
cat /root/.nulink/UTC*
```
copy all output and remember your keystore operator password
