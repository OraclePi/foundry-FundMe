-include .env
build:; forge build 
# test: ; forge test -vvvv
deploy-sepolia:
		forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC) \
		--broadcast --private-key $(PRIVATE_KEY) -vvvv --verify --etherscan-api-key $(API_KEY)