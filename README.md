## Diamond-3 using Foundry with AppStorage
* I didn't touch anything in the Diamond-3 template besides renaming the interfaces to be more explicit and replacing natspec with my own comments.
* Diamond Writeup here: xxxxxxxxxxx 

## Clone & Test
* There are no dependencies. The unit tests are re-done in foundry explicitly without needing string utils.
```bash
git clone https://github.com/alexbabits/diamond-3-foundry
forge test
```

## Deploy Locally
```bash
anvil # Then open 2nd bash terminal.
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" # This is a local private key from anvil.
forge script script/deployDiamond.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

## References
* EIP-2535 (Diamond Proxy Pattern): https://eips.ethereum.org/EIPS/eip-2535
* Diamond 3 (hardhat): https://github.com/mudgen/diamond-3
* Diamond-Foundry (uses diamond-1): https://github.com/FydeTreasury/Diamond-Foundry
* AppStorage: https://eip2535diamonds.substack.com/p/appstorage-pattern-for-state-variables
* Diamond Resource MegaThread: https://github.com/mudgen/awesome-diamonds/blob/main/README.md