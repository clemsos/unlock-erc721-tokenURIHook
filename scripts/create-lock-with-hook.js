const { unlock, ethers, run } = require("hardhat");

const { AddressZero } = ethers.constants

async function main() {
  
  // make sure we compile the latest versions 
  run("compile")

  // start workflow
  console.log("Unlock TokenURI Hook example:");

  // deploy NFT 
  const ExampleNFT = await ethers.getContractFactory("ExampleNFT");
  const nft = await ExampleNFT.deploy();
  await nft.deployed();
  console.log("> NFT deployed to:", nft.address);

  // deploy Unlock
  await unlock.deployProtocol()

  // create a Lock
  const lockArgs = {
    name: "TokenURI hook example",
    keyPrice: ethers.utils.parseEther('.1'),
    expirationDuration: 3600 * 24, // (24h)
    currencyContractAddress: AddressZero, // no ERC20 specified
    maxNumberOfKeys: 10
  }
  const { lock } = await unlock.createLock(lockArgs)
  console.log(`> Lock '${lockArgs.name}' deployed to:`, lock.address);

  // deploy the hook
  const LockTokenURIHook = await ethers.getContractFactory("LockTokenURIHook");
  const hook = await LockTokenURIHook.deploy();
  await hook.deployed();
  console.log("> Hook deployed to:", hook.address);

  // set NFT address in hook
  await hook.setNftContractAddress(nft.address);

  // set events hook
  await lock.setEventHooks(
    AddressZero,
    AddressZero,
    AddressZero,
    hook.address
  )

  // buy a token
  const [signer] = await ethers.getSigners()
  await lock.connect(signer)
    .purchase(
      0,
      signer.address, 
      AddressZero,
      AddressZero,
      [],
      {
        value: lockArgs.keyPrice
      })
  const keyId = await lock.getTokenIdFor(signer.address)
  console.log(`> Signer ${signer.address} bought the key ${keyId}`);
  
  // buy a NFT
  const tx = await nft.connect(signer).mint(signer.address)
  const { events } = await tx.wait()
  const { tokenId } = events[0].args
  console.log(`> Signer ${signer.address} bought the nft ${tokenId}`);

  // get tokenURI
  const tokenURI = await lock.tokenURI(keyId)
  console.log(tokenURI)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
