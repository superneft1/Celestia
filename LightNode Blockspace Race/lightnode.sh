#!/bin/sh

echo -e "\033[1mMazino Text Highlight\033[0m"

read -p "Enter a number:
1. Install Celestia
2. Check daemon logs in real time
Choice: " choice

if [[ "$choice" == "1" ]]; then
    read -p "Do you want to install Celestia? (y/n): " install_choice
    if [[ "$install_choice" =~ ^(y|Y)$ ]]; then
        sudo apt update && sudo apt upgrade -y

        sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y

        ver="1.19.1" 
        cd $HOME 
        wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 
        sudo rm -rf /usr/local/go 
        sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" 
        rm "go$ver.linux-amd64.tar.gz"

        echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
        source $HOME/.bash_profile

        go version

        cd $HOME 
        rm -rf celestia-node 
        git clone https://github.com/celestiaorg/celestia-node.git 
        cd celestia-node/ 
        git checkout tags/v0.8.0 
        make build 
        make install 
        make cel-key 

        celestia light init --p2p.network blockspacerace

        sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-lightd.service
        [Unit]
        Description=celestia-lightd Light Node
        After=network-online.target

        [Service]
        User=$USER
        ExecStart=celestia light start --core.ip https://grpc-blockspacerace.pops.one/ --keyring.accname my_celes_key --gateway --gateway.addr localhost --gateway.port 26659 --p2p.network blockspacerace --metrics.tls=false --metrics --metrics.endpoint otel.celestia.tools:4318
        Restart=on-failure
        RestartSec=3
        LimitNOFILE=4096

        [Install]
        WantedBy=multi-user.target
        EOF

        sudo systemctl enable celestia-lightd
        sudo systemctl start celestia-lightd

        echo "Celestia installation complete."
    else
        echo "Installation cancelled."
    fi
elif [[ "$choice" == "2" ]]; then
    sudo journalctl -u celestia-lightd.service -f
    echo "Check daemon logs in real time."
else
    echo "Invalid choice. Please enter either 1 or 2."
fi
