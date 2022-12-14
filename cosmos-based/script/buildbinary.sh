set -e
clear
echo -e "The process is running...\nPlease wait and don't kill the process until it's finished!!!"
echo -e -n "\e[36;1m"

# Updating packages
echo -e -n "[1/4] Updating and upgrading packages...\t"
sudo apt update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive \
  apt-get upgrade \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages >/dev/null 2>&1
echo "✔️"
sleep 1

# Installing dependencies
echo -n -e "[2/4] Installing dependencies...\t\t"
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y >/dev/null 2>&1
ver="1.19.3"
cd ~ >/dev/null 2>&1
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" >/dev/null 2>&1
sudo rm -rf $(which go) >/dev/null 2>&1
sudo rm -rf /usr/local/go >/dev/null 2>&1
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" >/dev/null 2>&1
rm "go$ver.linux-amd64.tar.gz" >/dev/null 2>&1
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
echo "export GOROOT=/usr/local/go" >> ~/.bash_profile
source ~/.bash_profile >/dev/null 2>&1
echo "✔️"
sleep 1

# Cloning binary
echo -n -e "[3/4] Cloning binary repo...\t\t\t"
cd ~
rm -rf $repo_dir >/dev/null 2>&1
git clone $repo >/dev/null 2>&1
echo "✔️"
sleep 1

# Build binary for testnet
if [[ $join_test == "true" ]]; then
  echo -n -e "[4/4] Building binary for "$testnet_chain_id"...\t\t"
  cd ~/$repo_dir >/dev/null 2>&1
  git fetch --all >/dev/null 2>&1
  git checkout $testnet_repo_tag >/dev/null 2>&1
  make install >/dev/null 2>&1
  echo -e "\e[0;96m✔️"
  sleep 1

# Build binary for mainnet
elif [[ $join_main == "true" ]]; then
  echo -n -e "[4/4] Building binary for "$mainnet_chain_id"...\t\t"
  cd ~/$repo_dir >/dev/null 2>&1
  git fetch --all >/dev/null 2>&1
  git checkout $mainnet_repo_tag >/dev/null 2>&1
  make install >/dev/null 2>&1
  echo -e "\e[0;96m✔️"
  sleep 2
fi

# Install cosmovisor
if [[ $with_cosmovisor == "true" ]]; then
  echo -e -n "\e[96;1m[+/+] Installing cosmovisor...\e[0;96m\t\t\t"
  cosmovisor_url="github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@latest"
  go install $cosmovisor_url >/dev/null 2>&1
  echo "✔️"
  sleep 2
fi
