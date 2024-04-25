## Deploy Locally
0. `anvil`, then open 2nd bash terminal.
1. `export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"`. This is a local private key from anvil.
2. `forge script script/deployDiamond.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast`

## Test
`forge test`