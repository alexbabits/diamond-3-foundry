## EIP-2535 Diamond Pattern for Morons
* **Problem**: There were too many ways to setup and build on top of the [Diamond proxy pattern](https://eips.ethereum.org/EIPS/eip-2535). When you just start out, each tutorial and reference feels just different enough to hinder your ability to learn what is going on. It took me a while to begin to grasp the different combinations and choices of implementations. And then you still have to digest all the information and pick a route hoping it was correct.
* **Solution**: An example repo that makes the best choices for you, and explicitly explains everything as if you were a moron.
* Note: This repo uses [diamond-3 template](https://github.com/mudgen/diamond-3) with Foundry and AppStorage. I didn't touch the template besides renaming the interfaces to be more explicit and replacing natspec with my own comments. I have also made some example dummy files for testing, ERC20 example, and ERC1155 example. Explanation of the layout is [here](#architecture).

### :warning: WARNING :warning:
* Please do NOT trust this code. Do NOT directly use in PRODUCTION. It has NOT been audited. Test and verify EVERYTHING. This is a repo for others like myself learning the diamond pattern. This repo is intended for education tailored at grasping the beginner concepts. 
* The `AppStorageRoot` technique is a new idea thought up on-the-spot by me that appears to help with the diamond structure when you want to use external templates and libraries like OpenZeppelin that already have storage. It could have bugs and issues.


### Clone & Test
```bash
git clone https://github.com/alexbabits/diamond-3-foundry
forge install # Installs OZ dependency, only needed for ERC20 and ERC1155 examples
forge test
```

### Deploy Locally
```bash
anvil # Then open 2nd bash terminal.
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" # This is a local private key from anvil.
forge script script/deployDiamond.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

### Education Start: Existential Questions
1. Why am I here? Most likely because you started building a contract that exceeded Vitalik's tiny 24kB contract size limit. (Or you a security researcher trying to quickly understand the Diamond Proxy Pattern that a protocol uses).
2. WTF is the Diamond Proxy Pattern? It just uses delegatecall under the hood like all popular proxy-implementation patterns to allow it's implementations to operate on the central proxy storage. Delegatecall can screw up your original storage if you aren't careful during upgrades.
3. How do I verify my diamond contract? IDK `¯\_(ツ)_/¯` I've never built anything worth any value that needed to be verified. People say Etherscan cannot view and verify diamonds properly, so [Louper](https://louper.dev/) was built to examine and verify testnet and mainnet diamond protocols.

### The Correct Stack [Diamond-3, AppStorage, Foundry, VSCode]
1. Starter Template Choices: [Diamond-1, Diamond-2, Diamond-3]. Best: **Diamond-3**. They are all similar and cover the core implementation of Diamond pattern. This is the latest one, it works fine.
2. Storage Organization Choices: [AppStorage, DiamondStorage]. Best: **AppStorage**. Much cleaner/easier, big protocols use it.
3. Tool Choices [Foundry, Hardhat, ...]. Best: **Foundry**. Hardhat is better if you really enjoy javascript over solidity.
4. IDE: [VSCode, Remix, ...]. Best: **VSCode**. Remix is better for quick mock-ups, but VSCode/IntelliJ/etc. is better actual serious projects imo.

### Basic Information
* The **Diamond** is the proxy. The **Facets** are the implementations. The diamond is a useless king. The facets are the slaves that labor for the king. The storage is all the resources brought back to the king.
* **DiamondLoupe**: View functions that provide information about the facets of your diamond.
* **DiamondCut**: This is your entire mechanism for adding/removing the implementations for a diamond. When "making a cut" with `diamondCut()` we are asking the question "what functions should go where?" The cut is the final thing you do after deploying a facet in order to connect it with your diamond as a proper implementation. Only public/external functions can "become part of a diamond".
    * **Adding** functions: We declare the `add` action and specify a facet and the functions in that facet.
    * **Replacing** functions: We declare the `replace` action and specify the new facet that should have the functions you want. The old facet will no longer have those functions. This removes functions from one facet, and adds them to another facet.
    * **Removing** functions: We declare the `remove` action and the functions we want to remove, and specify the zero address as the new home for these functions so they can no longer be used.
* **Storage Patterns**
    * **DiamondStorage**: Hashes a string to get a "random" slot for the diamond's central storage that prevents storage collision. The DiamondStorage struct is found in LibDiamond contract. The `Diamond.sol` proxy houses all the storage.
    * **AppStorage**: Found at slot 0 in the Diamond. When a facet accesses AppStorage, it accesses it at slot 0 of the Diamond, NOT the facet itself, because of the delegatecall inside the Diamond's fallback. This is how multiple facets are able to operate on the same AppStorage state values. Even though we say we are using "AppStorage", the core diamond template (Cut, Loupe, etc.) still uses diamond storage for itself. There is a separation of concerns between your **app's** storage and the actual **diamond's** storage. Note: I think you can technically replace the diamond storage references with AppStorage as well, but a lot of protocols seem to leave the core Diamond with diamondStorage pattern, and then their Application uses AppStorage.
* **DiamondInit**: Can be used to set diamond storage. This is supposed to be equivilant to the `initialize()` function that is traditionally found in upgradable contracts, where a constructor is disregarded in the implementation and instead `init()` is called. I find it better to just have `DiamondInit()` set the initial DiamondStorage of just the core diamond template files, and then for any facets you add beyond the diamond template you manually create your own `initialize()` function, and set any AppStorage needed from this function.
* `LibDiamond.enforceIsContractOwner();` is what we use for `onlyOwner` checks with the diamond.

## Architecture
This repo can be seen as having 4 "parts". It's recommended to first understand the basic concepts of the diamond, then learn the dummy examples, and then move on to actual real life token examples. This repo is commented in detail so you can learn quickly through looking at the code.

:warning: The last two parts with ERC20Facet and ERC1155Facet are "hand crafted" examples. Assume they have issues and bugs. :warning: 

1. Diamond template files needed to adhere to EIP-2535 that don't need to be touched.
2. Dummy Examples using AppStorage
3. ERC20Facet example using AppStorage.
4. ERC1155Facet example using AppStorage.

### Diamond template files
* `DiamondCutFacet.sol` = Used to make cuts. You don't need to know about how these functions work unless you want to, reading their names is sufficient.
* `DiamondLoupeFacet.sol` = Used to view your Diamond. You don't need to know about how these functions work unless you want to, reading their names is sufficient.
* `OwnershipFacet.sol` = IERC173 ownership standard, so only the owner can make cuts. (Not technically part of the standard, but essential).
* `IDiamondCutFacet.sol` = Interface for the Cut facet.
* `IDiamondLoupeFacet.sol` = Interface for the Loupe facet.
* `IERC173.sol` = Interface that can be used with Ownership facet.
* `IERC165.sol` = Nice to have interface to include the introspection standard.
* `LibDiamond.sol` = Core functions and storage declaration for your diamond.
* `DiamondInit.sol` = Allows you to set some initial storage for your diamond if you want.
* `Diamond.sol` = The centralized proxy that uses delegatecall when it's fallback function is provoked through an implementation facet.

### Dummy Examples
* `deployDiamond.s.sol` = Deploys diamond with foundry.
* `ExampleFacet.sol` = Dummy facet to test add/replace/remove functionality.
* `FacetWithAppStorage.sol` = Example facet to show you how AppStorage works, and to test AppStorage.
* `FacetWithAppStorage2.sol` = Example facet to show you how AppStorage works, and to test AppStorage.
* `AppStorage.sol` = The storage for all facets that isn't apart of the diamond template, anything outside the core diamond which uses DiamondStorage.
* `LibAppStorage.sol` = Useful optional library that protocols use to allow all their libraries to access AppStorage.
* `LibExample.sol` = An example of a library accessing AppStorage through LibAppStorage.
* `DiamondUnitTest.t.sol` = Provides unit tests for diamond functionality. 

### ERC20Facet Example
**Overview**: This example uses OpenZeppelin ERC20. There are many different ways to implement an ERC dependent facet in your diamond. I like a more explicit approach where you first dump everything from an ERC into one file and then decide if you want to inherit something or refactor it into separate interfaces. Regardless of the approach, you need to fully understand the anatomy of the ERC you want to implement. For all state changing functions, you are required to do some manual "surgery" by appending `s` to state variables, so that the ERC template works as intended with the AppStorage pattern of your Diamond pattern protocol. More clarity: Importing the `AppStorage.sol` file and referencing it's struct variables through `s.Var` is what allows the facet to operate on the centralized storage of the Diamond, allowing multiple facets to operate all on that same AppStorage with respect to the Diamond. 

**Facet Constructor Note**: When a facet has a constructor, any state that is set during construction resides in the actual facet itself, like with ERC20Facet. This is not a problem since we purposely have a dummy constructor only to satisfy the OZ requirement. We are always interacting with the ERC20Facet through the single diamond proxy address. If you were to interact directly with the ERC20Facet, you would see the empty strings for name and symbol, I think. "...data stored in a facet’s contract storage is ignored by a diamond... Immutable variables can be set in constructor functions of facets, because these are stored as part of a contract’s bytecode, and are not stored in contract storage. - Nick Mudge".

**Inheritance Note**: You cannot inherit an abstract contract that uses storage because that messes up the slot 0 placement where AppStorage should be. I fixed this problem with `AppStorageRoot.sol`. You could just not directly inherit and use any "template" contracts that already have storage.

* `ERC20Facet.sol` = ERC20 token example as a facet using AppStorage with OpenZeppelin template. It is possible to instead manually copy-paste all relevant ERC functions and interfaces so that you do not need to inherit ERC20 from OZ. Either way, the key is to make an `initialize()` function within the facet (function only callable once) to explicitly set any initial AppStorage for the facet in the context of the diamond.
* `IERC20Facet.sol` = Helpful interface with all of the public functions, errors, and events used with ERC20Facet.


### ERC1155Facet Example
* `ERC1155Facet.sol` = ERC1155 token example as a facet using AppStorage with OpenZeppelin template. Dummy constructor just like ERC20Facet. Must be initialized during deployment via `initialize()`.
* `IERC1155Facet.sol` = Helpful interface with all of the public functions, errors, and events used with ERC1155Facet.


## References
* EIP-2535 (Diamond Proxy Pattern): https://eips.ethereum.org/EIPS/eip-2535
* Diamond 3 (hardhat): https://github.com/mudgen/diamond-3
* Diamond-Foundry (uses diamond-1): https://github.com/FydeTreasury/Diamond-Foundry
* AppStorage: https://eip2535diamonds.substack.com/p/appstorage-pattern-for-state-variables
* Facets with constructors: https://eip2535diamonds.substack.com/p/constructor-functions-dont-work-in
* Diamond Resource MegaThread: https://github.com/mudgen/awesome-diamonds/blob/main/README.md