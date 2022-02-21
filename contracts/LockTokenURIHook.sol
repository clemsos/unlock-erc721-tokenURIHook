// SPDX-License-Identifier: MIT
pragma solidity >=0.5.17 <0.9.0;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@unlock-protocol/contracts/dist/PublicLock/IPublicLockV9.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import 'hardhat/console.sol';

/**
 * @notice Functions to be implemented by a tokenURIHook.
 * @dev Lock hooks are configured by calling `setEventHooks` on the lock.
 */
contract LockTokenURIHook
{

  address nftContractAddress;
  

  function setNftContractAddress(address _contractAddress) public {
    nftContractAddress = _contractAddress;
  }

  // see https://github.com/unlock-protocol/unlock/blob/master/smart-contracts/contracts/interfaces/hooks/ILockTokenURIHook.sol
  function tokenURI(
    address lockAddress,
    address, // operator,
    address owner, // owner,
    uint256, //keyId,
    uint //expirationTimestamp
  ) external view returns(string memory) {

    // set NFT contract
    require(nftContractAddress != address(0), "NFT_CONTRACT_NOT_SET");
    
    // check nft ownership
    IERC721 nft = IERC721(nftContractAddress);
    bool ownsNft = nft.balanceOf(owner) > 0;
    console.log('== owns nft:', ownsNft);
    
    // check key validity
    IPublicLockV9 lock = IPublicLockV9(lockAddress);
    bool hasValidKey = lock.getHasValidKey(owner);
    console.log('== has valid key:', hasValidKey);
    
    // custom logic
    string memory color = "grey";
    if(hasValidKey && ownsNft) {
      color =  "green";
    } else if(hasValidKey && !ownsNft) {
      color =  "orange";
    } else if(!hasValidKey && ownsNft) {
      color =  "red";
    }
    console.log('== color:', color);

    // draw svg
    string memory svg = string(
      abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 450 450"><title>',
        lock.name(),
        '</title><path d="M340.03287,180.49207H325.069V124.88428H269.47281v55.60779H180.64664V124.88428H125.05v55.60779H109.967v26.42028H125.05v41.62574c0,52.08154,45.05225,94.57763,100.3291,94.57763,54.957,0,99.68994-42.49609,99.68994-94.57763V206.91235h14.96387Zm-70.56006,68.046c0,24.603-19.49072,44.73242-44.09375,44.73242a44.86368,44.86368,0,0,1-44.73242-44.73242V206.91235h88.82617Z" style="fill:',
        color,
        '"/></svg>'
      )
    );

    return string(
          abi.encodePacked(
              "data:image/svg+xml;base64,",
              Base64.encode(
                  bytes(
                      abi.encodePacked(svg)
                  )
              )
          )
      );

  }
}