Note: In this implementation the loupe functions are NOT gas optimized. The facets, facetFunctionSelectors, facetAddresses loupe functions are not meant to be called on-chain and may use too much gas or run out of gas when called in on-chain transactions. In this implementation these functions should be called by off-chain software like websites and Javascript libraries etc., where gas costs do not matter.

## My way
`export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"`
`forge script script/deployDiamond.s.sol --ffi --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast`
`forge test --ffi --match-path test/DiamondTests.t.sol`
// Requires `https://github.com/Arachnid/solidity-stringutils`