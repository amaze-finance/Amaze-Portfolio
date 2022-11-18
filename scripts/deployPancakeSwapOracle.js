const hre = require("hardhat");
const { BigNumber, utils } = require("ethers");
const hardhat = require("hardhat");

async function main() {

  const Oracle = await ethers.getContractFactory("PancakeSwapPriceFeed");

  const oracle = await Oracle.deploy();
  await oracle.deployed();

  console.log("Token deployed to:", oracle.address);

  console.log("Waiting for 5 confirmations")
  await oracle.deployTransaction.wait(5)
  console.log("Confirmed!")

  console.log("Verifying...")
  await hardhat.run("verify:verify", {
    address: oracle.address,
    constructorArguments: [],
  })
  console.log("VERIFICATION COMPLETE")

}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

