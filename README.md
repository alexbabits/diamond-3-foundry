## EIP-2535 Diamond Pattern for Morons
* I'm a noob. You are too. 
* **Problem**: There are too many ways to setup the Diamond proxy pattern. When you are just starting out, each tutorial and reference is just different enough to fuck up your ability to learn anything. My peanut brain took far too long to comprehend the different flavors, combinations, and choices of implementations (and then digest all the information, and then pick one hoping it was correct).
* **Solution**: An example repo that makes the best choices for you, and explicitly explains everything as if you were retarded.
* Note: This repo uses diamond-3 template with foundry and AppStorage.
* Note: I didn't touch anything in the Diamond-3 template besides renaming the interfaces to be more explicit and replacing natspec with my own comments. There are some example files in addition to the template.

### Clone & Test
* There are no dependencies. The unit tests are re-done in foundry.
```bash
git clone https://github.com/alexbabits/diamond-3-foundry
forge test
```

### Deploy Locally
```bash
anvil # Then open 2nd bash terminal.
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" # This is a local private key from anvil.
forge script script/deployDiamond.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

### Education Start: Existential Questions
1. Why am I here? Most likely because you started building a protocol that exceeded Vitalik's tiny 24kB contract size limit.
2. What the fuck is the Diamond Proxy Pattern? It just uses delegatecall under the hood like all popular proxy-implementation patterns to allow it's implementations to operate on the central proxy storage. Delegatecall can fuck up your original storage if you aren't careful during upgrades.
3. How do I verify my diamond contract? I don't fucking know `¯\_(ツ)_/¯` I've never built anything worth any value that needed to be verified, and neither will you. People say Etherscan is too retarded to view diamonds properly, so `Louper` was built to examine testnet and mainnet diamond protocols.

### The Correct Stack [Diamond-3, AppStorage, Foundry, VSCode]
1. Storage Organization Choices: [AppStorage, DiamondStorage]. Best: **AppStorage**. Much cleaner, big protocols use it.
2. Starter Template Choices: [Diamond-1, Diamond-2, Diamond-3]. Best: **Diamond-3**. They are all similar and cover the core implementation of Diamond pattern. This is the latest one, it works fine.
3. Tool Choices [Foundry, Hardhat, ...]. Best: **Foundry**. Hardhat is for Solidity boomers and nerds. Anything else is for weirdos.
4. IDE: [VSCode, Remix, ...]. Best: **VSCode**. Remix and anything else is for weirdos. 

### Basic Bitch Information
* The **Diamond** is the proxy. The **Facets** are the implementations. The diamond is a useless king. The facets are the slaves that labor for the king. The storage is all the resources brought back to the king.
* **Loupe**: Provides information about the facets in a Diamond via 4 view functions.
* **Cut**: This is your entire mechanism for adding/removing the implementations for a diamond. When making a cut, you specify the facet address, what you want to do with the facet (add/remove/replace), and the function selectors you want associated with the facet. 
* **Init**: Used to set the initial diamond storage.

### Architecture
There are two kinds of files in this repo.
1. Diamond template files needed to adhere to EIP-2535 that don't need to be touched.
2. Useful example files to show you how it all works.

**Diamond template files**:
* `DiamondCutFacet.sol` = Used to make cuts. You don't need to know about how these functions work unless you want to, reading their names is sufficient.
* `DiamondLoupeFacet.sol` = Used to view your Diamond. You don't need to know about how these functions work unless you want to, reading their names is sufficient.
* `OwnershipFacet.sol` = IERC173 ownership standard, so only the owner can make cuts. (Not technically part of the standard, but essential).
* `IDiamondCutFacet.sol` = Interface for the Cut facet.
* `IDiamondLoupeFacet.sol` = Interface for the Loupe facet.
* `IERC173.sol` = Interface that can be used with Ownership facet.
* `IERC165.sol` = Nice to have interface to include the introspection standard.
* `LibDiamond.sol` = Core functions and storage declaration for your diamond.
* `DiamondInit.sol` = Allows you to set initial storage for your diamond.
* `Diamond.sol` = The proxy that uses delegatecall through it's fallback function, executing the facet functions when provoked.

**Useful example files**:
* `deployDiamond.s.sol` = Deploys diamond with foundry.
* `ExampleFacet.sol` = Dummy facet to test add/replace/remove functionality.
* `FacetWithAppStorage.sol` = Example facet to show you how AppStorage works, and to test AppStorage.
* `FacetWithAppStorage2.sol` = ditto.
* `LibAppStorage.sol` = Useful library that protocols use to allow all their libraries to access AppStorage.
* `LibExample.sol` = An example of a library accessing AppStorage through LibAppStorage.
* `AppStorage.sol` = The storage for facets that aren't apart of the diamond template, basically anything outside of the core diamond which uses DiamondStorage. Even though we say we are using "AppStorage", the core diamond template still uses diamond storage for itself. There is a separation of concerns between your **app's** storage and the actual **diamond's** storage.
* `DiamondUnitTest.t.sol` = Provides unit tests for diamond functionality. 

Happy Building!

## References
* EIP-2535 (Diamond Proxy Pattern): https://eips.ethereum.org/EIPS/eip-2535
* Diamond 3 (hardhat): https://github.com/mudgen/diamond-3
* Diamond-Foundry (uses diamond-1): https://github.com/FydeTreasury/Diamond-Foundry
* AppStorage: https://eip2535diamonds.substack.com/p/appstorage-pattern-for-state-variables
* Diamond Resource MegaThread: https://github.com/mudgen/awesome-diamonds/blob/main/README.md