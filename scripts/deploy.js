const hre = require("hardhat");
const { BigNumber, utils } = require("ethers");
const hardhat = require("hardhat");


function ether(eth) {
  let weiAmount = ethers.utils.parseEther(eth)
  return weiAmount;
}

// address owner_,
//         address cinemaAddress_,
//         string memory tokenName_,
//         string memory tokenSymbol_

async function main() {

  const Token = await ethers.getContractFactory("Token");

  const token = await Token.deploy( // with arguments
    "0x29572D9CC8c8687303D28Ab5eD7c96e1Cee2aE91", // address owner 
    "404.cinema", // name
    "404", // symbol
  );
  await token.deployed();

  console.log("Token deployed to:", token.address);

  console.log("Waiting for 5 confirmations")
  await token.deployTransaction.wait(5)
  console.log("Confirmed!")

  console.log("Verifying...")
  await hardhat.run("verify:verify", {
    address: token.address,
    constructorArguments: [
    "0x29572D9CC8c8687303D28Ab5eD7c96e1Cee2aE91", // address owner 
    "404.cinema", // name
    "404",  ],
  })
  console.log("VERIFICATION COMPLETE")

}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

