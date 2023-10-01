# Some random token testing

THIS IS NOT PRODUCTION CODE.

```bash
forge init
forge install openzeppelin/openzeppelin-contracts --no-commit
forge install vectorized/solady --no-commit
```

Deploy an NFT contract. Each mint/burn is a buy sell that follows a bonding curve.

Test: `forge test -vvvv`
Deploy factory: `forge script script/DeployCTFactory.s.sol --rpc-url http://127.0.0.1:8545 --broadcast -vvvv`.
Run it in anvil: `anvil --fork-url https://developer-access-mainnet.base.org --block-time 10`
