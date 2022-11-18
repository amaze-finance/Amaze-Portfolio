const { expect } = require("chai");
const { BigNumber, utils } = require("ethers");
const { ethers, deployments } = require("hardhat");
const hre = require("hardhat");
const hardhat = require("hardhat");

function ether(eth) {
    let weiAmount = ethers.utils.parseEther(eth)
    return weiAmount;
}


  const MORALIS_URL = process.env.MORALIS_URL
  const API_KEY = process.env.API_KEY
  const privateKey = process.env.PRIVATE_KEY
  const address = process.env.ADDRESS;
  const provider = new ethers.providers.JsonRpcProvider(MORALIS_URL)
  let wallet = new ethers.Wallet(privateKey, provider)
  
const ABI = [
    "function ETHgetLatestPrice() returns (int)",
    "function getLatestPrice(IAggregatorV3Interface priceFeed) returns (int)"
];

const contract = new ethers.Contract(
    '0x1D0a3e2AE22Dc965428c4365498b8B5f1853fe31',
    ABI,
    provider
)


describe ("PriceFeed", async function () {
    let owner, user1, user2, user3;

    describe("ETH price feed", async function () {
        it("Getting price", async function () {
            const contractWithWallet = contract.connect(wallet)

            const getPrice = await contractWithWallet.ETHgetLatestPrice()
            // await getPrice.wait()

            console.log(getPrice)
            expect(await contract.ETHgetLatestPrice()).to.equal(getPrice);
        });
    });
});
    