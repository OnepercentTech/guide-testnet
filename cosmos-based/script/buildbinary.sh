set -e
clear
echo -e "The process is running...\nPlease wait and don't kill the process until it's finished!!!"
echo -e -n "\e[36;1m"

# Updating packages
echo -e -n "[1/4] Updating and upgrading packages...\t"
sudo apt update 2>&1 >/dev/null
DEBIAN_FRONTEND=noninteractive \
  apt-get upgrade \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages 2>&1 >/dev/null
echo "✅️"
sleep 1

# Installing dependencies
echo -n -e "[2/4] Installing dependencies...\t\t"
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool xmlstarlet -y 2>&1 >/dev/null
ver="1.19.4"
cd ~ 2>&1 >/dev/null
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 2>&1 >/dev/null
sudo rm -rf $(which go) 2>&1 >/dev/null
sudo rm -rf /usr/local/go 2>&1 >/dev/null
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" 2>&1 >/dev/null
rm "go$ver.linux-amd64.tar.gz" 2>&1 >/dev/null
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
echo "export GOROOT=/usr/local/go" >> ~/.bash_profile
source ~/.bash_profile 2>&1 >/dev/null
sudo curl https://get.ignite.com/cli! 2>&1 >/dev/null | sudo bash 2>&1 >/dev/null
echo "✅️"
sleep 1

# Cloning binary
echo -n -e "[3/4] Cloning binary repo...\t\t\t"
cd ~
rm -rf $repo_dir 2>&1 >/dev/null
git clone $repo 2>&1 >/dev/null
echo "✅️"
sleep 1

# Build binary for testnet
if [[ $join_test == "true" ]]; then
  echo -n -e "[4/4] Building binary for "$testnet_chain_id"...\t\t"
  cd ~/$repo_dir 2>&1 >/dev/null
  git fetch --all 2>&1 >/dev/null
  git checkout $testnet_repo_tag 2>&1 >/dev/null
  make install 2>&1 >/dev/null || ignite chain build 2>&1 >/dev/null
  echo -e "\e[0;96m✅️"
  sleep 1

# Build binary for mainnet
elif [[ $join_main == "true" ]]; then
  echo -n -e "[4/4] Building binary for "$mainnet_chain_id"...\t\t"
  cd ~/$repo_dir 2>&1 >/dev/null
  git fetch --all 2>&1 >/dev/null
  git checkout $mainnet_repo_tag 2>&1 >/dev/null
  make install 2>&1 >/dev/null || ignite chain build 2>&1 >/dev/null
  echo -e "\e[0;96m✅️"
  sleep 1
fi

# Install cosmovisor
if [[ $with_cosmovisor == "true" ]]; then
  echo -e -n "\e[96;1m[+/+] Installing cosmovisor...\e[0;96m\t\t\t"
  cosmovisor_url="github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@latest"
  go install $cosmovisor_url 2>&1 >/dev/null
  echo "✅️"
  sleep 2
fi
