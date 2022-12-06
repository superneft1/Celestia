source $HOME/.bash_profile

#function Run a Validator Node
echo -e "\e[1m\e[32mRun a Validator Node \e[0m" && sleep 1

celestia-appd tx staking create-validator -y \
  --amount 10000000utia \
  --from $WALLET \
  --moniker $NODENAME \
  --pubkey  $(celestia-appd tendermint show-validator) \
  --commission-rate=0.1 \
  --commission-max-rate=0.2 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation=1000000 \
  --keyring-backend=test \
  --chain-id mamaki
  
  sleep 60
  
celestia-appd tx slashing unjail --from=$WALLET_ADDRESS --chain-id=mamaki -y

    
  
  echo "==========================================================================================================================="