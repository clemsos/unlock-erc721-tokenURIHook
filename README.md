# Unlock ERC721 TokenURI hook

This is a sample project to show how [Unlock Protocol](https://unlock-protocol.com) `onTokenURIHook` can be used to return a custom SVG when `tokenURI` is fetched.

### How it works

There are 3 elements to the project :

1. the Unlock contracts (deployed using the [Unlock hardhat plugin]([https://npmjs](https://www.npmjs.com/package/@unlock-protocol/hardhat-plugin)))
2. a typical NFT contract (using [OpenZeppelin ERC721](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721) implementation)
3. a custom contract to store the hook logic

Once the `tokenURIHook` is set in the lock, the hook contract will be used to return the URI.

In the hook contract, the color of the SVG changes based on the NFT and Lock ownership (green if caller owns a nft and a valid key, orange is caller only owns a valid key but no nft, etc).
### Run the project

```shell
# install deps
yarn # or npm install

# run the script
npx hardhat run scripts/create-lock-with-hook.js
```



