// const { expect } = require("chai");
// const { BigNumber, utils } = require("ethers");
// const { ethers, deployments } = require("hardhat");

// function ether(eth) {
//     let weiAmount = ethers.utils.parseEther(eth)
//     return weiAmount;
// }

// async function getLatestBlockTimestamp() {
//     return (await ethers.provider.getBlock("latest")).timestamp || 0;
// }
  
// async function skipTimeTo(timestamp) {
//     await network.provider.send("evm_setNextBlockTimestamp", [timestamp]);
//     await network.provider.send("evm_mine");
// }

// async function getUserInfo(address, startSubscription, period, idNFT) {
//     let User = await cinema.userInfo(address);

//     expect(User[0]).to.equal(startSubscription);
//     expect(User[1]).to.equal(period);
//     expect(User[2]).to.equal(idNFT);
  
//   }

// // const DAY = 86400;
// // const MONTH = 2592000;
// // const TWO_DAYS = 172800;


// describe ("Cinema", async function () {
//     let owner, user1, user2, user3;

//     beforeEach ("Deploy the contract", async function () {
//         [owner, user1, user2, user3] = await ethers.getSigners();

//         USDT = await ethers.getContractFactory("MockERC20");
//         usdt = await USDT.deploy(500);
//         await usdt.deployed();

//         NFT = await ethers.getContractFactory("NFT");
//         nft = await NFT.deploy(
//           user3.address, // special address
//         );
//         await nft.deployed();

//         Portfolio = await ethers.getContractFactory("Portfolio");
//         portfolio = await Portfolio.deploy(
          
//           dai.address,
//           token.address,
//           owner.address,
//           nft.address,
//           5, // sale fee
//           1, // usual multiplier
//           ether("15"), // usual subscription cost
//         );
//         await portfolio.deployed();

//         // constructor (
//         //     NFT amaze_,
//         //     IERC20 paymentToken_,
//         //     address native_,
//         //     address payable feeKeeper_,
//         //     uint256 cost_,
//         //     uint256 fee_,
//         //     address specialAddress_
//         // ) {
//         //     amaze = amaze_;
//         //     paymentToken = paymentToken_;
//         //     native = native_;
//         //     feeKeeper = feeKeeper_;
//         //     cost = cost_;
//         //     fee = fee_;
//         //     specialAddresses[specialAddress_] = true;
//         //     specialAddresses[msg.sender] = true;
//         // }

//         // set special addresses
//         expect(await token.specialAddresses(nft.address)).to.equal(false);
//         expect(await token.connect(owner).setSpecialAddress(nft.address));
//         expect(await token.specialAddresses(nft.address)).to.equal(true);

//         expect(await token.specialAddresses(cinema.address)).to.equal(false);
//         expect(await token.connect(owner).setSpecialAddress(cinema.address));
//         expect(await token.specialAddresses(cinema.address)).to.equal(true);

//         // expect nft and token deployed params
//         expect(await token.balanceOf(owner.address)).to.equal(ether("0"));
//         expect(await token.balanceOf(token.address)).to.equal(ether("0"));
//         expect(await nft.balanceOf(owner.address)).to.equal(0);
//         expect(await nft.balanceOf(user1.address)).to.equal(0);
//         expect(await nft.balanceOf(user2.address)).to.equal(0);
//         expect(await nft.balanceOf(user3.address)).to.equal(0);
//         expect(await nft.cost()).to.equal(ether("15"));
//         expect(await nft.saleFee()).to.equal(5);
//         expect(await nft.maximumLevel()).to.equal(2);

//         // mint company token to users
//         expect(await token.connect(owner).mint(owner.address, ether("500")));
//         expect(await token.connect(owner).changeMintOnce());
//         expect(await token.connect(owner).mint(user1.address, ether("500")));
//         expect(await token.connect(owner).changeMintOnce());
//         expect(await token.connect(owner).mint(user2.address, ether("500")));
//         expect(await token.connect(owner).changeMintOnce());
//         expect(await token.balanceOf(owner.address)).to.equal(ether("500"));
//         expect(await token.balanceOf(user1.address)).to.equal(ether("500"));
//         expect(await token.balanceOf(user2.address)).to.equal(ether("500"));

//         // transfer dai to user1
//         expect(await dai.connect(owner).transfer(user1.address, ether("100")));
//         expect(await dai.balanceOf(owner.address)).to.equal(ether("400"));
//         expect(await dai.balanceOf(user1.address)).to.equal(ether("100"));

//         // mint to user1 nft
//         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//         expect(await token.connect(user1).approve(nft.address, ether("100")));
//         expect(await nft.connect(user1).mint());
//         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));
//     });

//     // function buySubscription(
//     //     uint256 _periodSubscription,
//     //     uint256 _costSubscription,
//     //     uint256 _idNFT
//     // ) external {
//     //     address _msgSender = msg.sender;
//     //     require
//     //     (
//     //         block.timestamp - userInfo[_msgSender].startSubscription < userInfo[_msgSender].periodSubscription,
//     //         "You have valid Subscription"
//     //     );
//     //     if (_tokenId == 0) {
//     //         addressToken.transferFrom(_msgSender, address(this), cost);
//     //         userInfo[_msgSender] = User(block.timestamp, _periodSubscription, 0);
//     //     } else {
//     //         uint256[] memory _indexesOnSale = onSaleSeats[_idNFT];
//     //         uint256 _size = _indexesOnSale.length;
//     //         for (uint256 i = 0; i < _size;) {
//     //             if (_costSubscription == infoNFTs[_idNFT][i].price && infoNFTs[_idNFT][i].user == address(0)) {
//     //                 uint256 _comission = _costSubscription * fee / 100;
//     //                 addressToken.transferFrom(_msgSender, addressNFT.getOwnerNFT(_idNFT), _costSubscription - _comission);
//     //                 addressToken.transferFrom(_msgSender, addressNFT.getOwnerNFT(_idNFT), _comission);
//     //                 infoNFTs[_idNFT][i].user = _msgSender;
//     //                 userInfo[_msgSender] = User(block.timestamp, _periodSubscription, _idNFT);
//     //                 i = _size - 1;
//     //             }
//     //             unchecked { i++; }
//     //         }
//     //     }

//     describe("buySubscription test", async function () {
//         it("You have valid Subscription", async function () {
//             expect(await token.balanceOf(user1.address)).to.equal(ether("485"));
//             expect(await token.connect(user1).approve(cinema.address, ether("100")));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("0"));
//             expect(await cinema.connect(user1).buySubscription(MONTH, 0, 0));
            
//             expect(await token.balanceOf(user1.address)).to.equal(ether("470"));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("15"));
//             getUserInfo(user1.address, await getLatestBlockTimestamp(), MONTH, 0)
            
//             await expect (cinema.connect(user1).buySubscription(MONTH, 0, 0)).to.be.revertedWith("You have valid Subscription");
//             // test buy subcription after month 
//             await skipTimeTo((await getLatestBlockTimestamp()) + MONTH);

//             expect(await token.balanceOf(user1.address)).to.equal(ether("470"));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("15"));

//             expect(await cinema.connect(user1).buySubscription(MONTH, 0, 0));
//             expect(await token.balanceOf(user1.address)).to.equal(ether("455"));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("30"));
//             getUserInfo(user1.address, getLatestBlockTimestamp(), MONTH, 0)

//         });
//         it("Buy company subscription", async function () {
//             expect(await token.balanceOf(user1.address)).to.equal(ether("485"));
//             expect(await token.connect(user1).approve(cinema.address, ether("100")));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("0"));
//             expect(await cinema.connect(user1).buySubscription(MONTH, 0, 0));
            
//             expect(await token.balanceOf(user1.address)).to.equal(ether("470"));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("15"));
//             getUserInfo(user1.address, getLatestBlockTimestamp(), MONTH, 0)
//         });
//     });

//     // /// @notice transfering rewards in tokens for watching films
//     // /// @param _watchingPeriod period of time in seconds
//     // function transferReward(uint256 _watchingPeriod) external SpecialAddress {
//     //     address _msgSender = msg.sender;
//     //     require
//     //     (
//     //         block.timestamp - userInfo[_msgSender].startSubscription > userInfo[_msgSender].periodSubscription,
//     //         "You don't have valid Subscription"
//     //     );
//     //     require(_watchingPeriod > 0, "Watching period shoul not be ZERO");
//     //     addressToken.transfer(_msgSender, calculateReward(_msgSender, _watchingPeriod));

//     // }

//     describe("transferReward test", async function () {
//         it("You have valid Subscription", async function () {
//             expect(await token.balanceOf(user2.address)).to.equal(ether("500"));
//             expect(await token.connect(user2).approve(cinema.address, ether("100")));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("0"));
//             expect(await cinema.connect(user2).buySubscription(MONTH, 0, 0));
            
//             expect(await token.balanceOf(user2.address)).to.equal(ether("485"));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("15"));
//             getUserInfo(user2.address, await getLatestBlockTimestamp(), MONTH, 0)

//             expect(await cinema.connect(owner).transferReward(user2.address, 5));

//             expect(await token.balanceOf(user2.address)).to.equal(ether("490"));
//             expect(await token.balanceOf(cinema.address)).to.equal(ether("10"));
            
//             // await expect (cinema.connect(user1).buySubscription(MONTH, 0, 0)).to.be.revertedWith("You have valid Subscription");
//             // // test buy subcription after month 
//             // await skipTimeTo((await getLatestBlockTimestamp()) + MONTH);

//             // expect(await token.balanceOf(user1.address)).to.equal(ether("470"));
//             // expect(await token.balanceOf(cinema.address)).to.equal(ether("15"));

//             // expect(await cinema.connect(user1).buySubscription(MONTH, 0, 0));
//             // expect(await token.balanceOf(user1.address)).to.equal(ether("455"));
//             // expect(await token.balanceOf(cinema.address)).to.equal(ether("30"));
//             // getUserInfo(user1.address, getLatestBlockTimestamp(), MONTH, 0)

//         });
//         it("Buy company subscription", async function () {
//             // expect(await token.balanceOf(user1.address)).to.equal(ether("485"));
//             // expect(await token.connect(user1).approve(cinema.address, ether("100")));
//             // expect(await token.balanceOf(cinema.address)).to.equal(ether("0"));
//             // expect(await cinema.connect(user1).buySubscription(MONTH, 0, 0));
            
//             // expect(await token.balanceOf(user1.address)).to.equal(ether("470"));
//             // expect(await token.balanceOf(cinema.address)).to.equal(ether("15"));
//             // getUserInfo(user1.address, getLatestBlockTimestamp(), MONTH, 0)
//         });
//     });

//     describe("getTokenBalance", async function () {
//         it("getTokenBalance", async function () {
//             expect(await cinema.connect(owner).getTokenBalance(token.address)).to.equal(ether("0"));
//             expect(await cinema.connect(owner).getTokenBalance(dai.address)).to.equal(ether("0"));
//         });
//     });

//     // describe("Mint NFT", async function () {

//     //     it("Not enough balanse to mint", async function () {
//     //         expect(await nft.connect(user2).balanceOf(user2.address)).to.equal(0);
//     //         expect(await token.connect(user2).approve(nft.address, ether("100")));
//     //         expect(await token.connect(user2).transfer(nft.address, ether("500")));
//     //         await expect (nft.connect(user2).mint()).to.be.revertedWith("Not enough token amount");
//     //     });

//     //     it("Not enough alowed Supply", async function () {
//     //         expect(await nft.connect(user2).balanceOf(user2.address)).to.equal(0);
//     //         expect(await token.connect(user2).approve(nft.address, ether("100")));
//     //         expect(await token.connect(user2).transfer(nft.address, ether("500")));
//     //         await expect (nft.connect(user2).mint()).to.be.revertedWith("Not enough token amount");
//     //     });

//         // it("Success mint", async function () { 
//         //     expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//         //     expect(await token.connect(user1).approve(nft.address, ether("100")));
//         //     expect(await nft.connect(user1).mint());
//         //     expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//         //     expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));
//         //     expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("15"));
//         //     expect(await nft.connect(user1).getOwnerNFT(1)).to.equal(user1.address);
//         //     expect(await nft.connect(user1).getLevelNFT(1)).to.equal(0);
//         //     expect(await nft.connect(user1).getMultiplier(1)).to.equal(1);
//         //     expect(await nft.connect(user1).getSeats(1)).to.equal(0);
            
//         //     console.log("Not enough alowed Supply")
//         //     await expect (nft.connect(user1).mint()).to.be.revertedWith("Not enough alowed Supply");
            
//         //     console.log("Upgrade NFT")
//         //     await skipTimeTo((await getLatestBlockTimestamp()) + DAY);
        
//         //     expect(await nft.connect(user1).upgrade(1));
//         //     expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//         //     expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("475"));
//         //     expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("25"));

//     //         console.log("Second mint")
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(2);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("460"));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("40"));
//     //         expect(await nft.connect(user1).getOwnerNFT(1)).to.equal(user1.address);
//     //         expect(await nft.connect(user1).getLevelNFT(1)).to.equal(1);
//     //         expect(await nft.connect(user1).getMultiplier(1)).to.equal(2);
//     //         expect(await nft.connect(user1).getSeats(1)).to.equal(1);

//     //         expect(await nft.connect(owner).balanceOf(owner.address)).to.equal(0);
//     //         expect(await token.connect(owner).balanceOf(owner.address)).to.equal(ether("500"));
//     //         expect(await token.connect(owner).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(owner).mint());
//     //         expect(await nft.connect(owner).balanceOf(owner.address)).to.equal(1);
//     //         expect(await token.connect(owner).balanceOf(owner.address)).to.equal(ether("485"));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("55"));
//     //     });
//     // });

//     // describe("Upgrade NFT requires", async function () {
//     //     it("Wait time for next upgrade", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         await expect (nft.connect(user1).upgrade(1)).to.be.revertedWith("Wait time for next upgrade");
//     //     });

//     //     it("Not user's NFT", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await token.connect(user2).balanceOf(user2.address)).to.equal(ether("500"));
//     //         expect(await token.connect(user2).approve(nft.address, ether("100")));
//     //         await skipTimeTo((await getLatestBlockTimestamp()) + DAY);
//     //         await expect (nft.connect(user2).upgrade(1)).to.be.revertedWith("Not user's NFT");
//     //     });

//     //     it("Not enough token amount", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         await skipTimeTo((await getLatestBlockTimestamp()) + DAY);
//     //         expect(await token.connect(user1).transfer(nft.address, ether("485")));
//     //         await expect (nft.connect(user1).upgrade(1)).to.be.revertedWith("Not enough token amount");
//     //     });

//     //     it("Already the maximum level", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("15"));

//     //         await skipTimeTo((await getLatestBlockTimestamp()) + DAY);
        
//     //         expect(await nft.connect(user1).upgrade(1));
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("475"));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("25"));

//     //         await skipTimeTo((await getLatestBlockTimestamp()) + TWO_DAYS);
//     //         await expect (nft.connect(user1).upgrade(1)).to.be.revertedWith("Already the maximum level");
//     //     });

//     //     it("Sorry your NFT on sale", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));
//     //         await skipTimeTo((await getLatestBlockTimestamp()) + TWO_DAYS);
//     //         await expect (nft.connect(user1).upgrade(1)).to.be.revertedWith("Sorry your NFT on sale");
//     //     });
//     // });

//     // describe("Sale NFT", async function () {
//     //     it("Not user's NFT", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await token.connect(user2).balanceOf(user2.address)).to.equal(ether("500"));
//     //         expect(await token.connect(user2).approve(nft.address, ether("100")));
//     //         await expect (nft.connect(user2).setToSale(1, ether("10"))).to.be.revertedWith("Not user's NFT");
//     //     });

//     //     it("Use function with wrong arguments", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         await expect (nft.connect(user1).setToSale(true, ether("10"))).to.be.reverted;
//     //     });

//     //     it("Correct set to sale", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));
//     //     });

//     //     it("Set to sale twice", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));
//     //         await expect (nft.connect(user1).setToSale(1, ether("11"))).to.be.revertedWith("This NFT already on sale");
//     //     });
//     // });

//     // describe("Set changes to sale NFT", async function () {
//     //     it("This NFT not on a sale", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         await expect (nft.connect(user1).changeSaleInfo(1, ether("11"))).to.be.revertedWith("This NFT not on a sale");
//     //     });

//     //     it("Not user's NFT", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));

//     //         await expect (nft.connect(user2).changeSaleInfo(1, ether("11"))).to.be.revertedWith("Not user's NFT");
//     //     });

//     //     it("Correct set changes", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));

//     //         expect(await nft.connect(user1).changeSaleInfo(1, ether("11")));
//     //     });
//     // });

//     // describe("Delete from sale NFT", async function () {
//     //     it("This NFT not on a sale", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         await expect (nft.connect(user1).deleteFromSale(1)).to.be.revertedWith("This NFT not on a sale");
//     //     });
//     //     it("Not user's NFT", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));

//     //         await expect (nft.connect(user2).deleteFromSale(1)).to.be.revertedWith("Not user's NFT");
//     //     });

//     //     it("Correct delete", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));
//     //         let nftInfo = await nft.getOnSaleNFTs();
//     //         console.log(nftInfo);
//     //         expect(await nft.connect(user1).deleteFromSale(1));
//     //         nftInfo = await nft.getOnSaleNFTs();
//     //     });
//     // });

//     // describe("Buy NFT", async function () {
//     //     it("This NFT not on a sale", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await token.connect(user2).balanceOf(user2.address)).to.equal(ether("500"));
//     //         expect(await token.connect(user2).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).approve(nft.address, 1));
//     //         await expect (nft.connect(user2).buy(1)).to.be.revertedWith("This NFT not on a sale");
//     //     });

//     //     it("Not enough token amount", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));

//     //         expect(await token.connect(user2).balanceOf(user2.address)).to.equal(ether("500"));
//     //         expect(await token.connect(user2).approve(nft.address, ether("100")));
//     //         expect(await token.connect(user2).transfer(nft.address, ether("500")));
//     //         expect(await token.connect(user2).balanceOf(user2.address)).to.equal(ether("0"));
//     //         expect(await nft.connect(user1).approve(nft.address, 1));
//     //         await expect (nft.connect(user2).buy(1)).to.be.revertedWith("Not enough token amount");
//     //     });

//     //     it("Correct buy", async function () {
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await token.connect(user1).approve(nft.address, ether("100")));
//     //         expect(await nft.connect(user1).mint());
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(1);
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("485"));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("15"));

//     //         expect(await nft.connect(user1).setToSale(1, ether("10")));
            
//     //         expect(await token.connect(user2).balanceOf(user2.address)).to.equal(ether("500"));
//     //         expect(await token.connect(user2).approve(nft.address, ether("100")));
//     //         // expect(await nft.connect(user1).approve(user2.address, 1));
        
//     //         expect(await nft.connect(user2).buy(1));
            
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("494.5"));
//     //         expect(await token.connect(user2).balanceOf(user2.address)).to.equal(ether("490"));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("15.5"));
//     //         expect(await nft.connect(user1).balanceOf(user1.address)).to.equal(0);
//     //         expect(await nft.connect(user2).balanceOf(user2.address)).to.equal(1);
//     //     });
//     // });

//     // describe("WithdrawNFTs", async function () {
//     //     it("Not special address", async function () {
//     //         await expect (nft.connect(user2).withdrawNFTs(2, owner.address)).to.be.revertedWith("Not special address");
//     //     });

//     //     it("Special address", async function () {
//     //         expect(await nft.connect(owner).withdrawNFTs(2, owner.address));
//     //         expect(await nft.connect(owner).balanceOf(owner.address)).to.equal(2);
//     //     });
//     // });

//     // describe("withdrawTokensERC20", async function () {
//     //     it("Not special address", async function () {
//     //         await expect (nft.connect(user2).withdrawTokensERC20(token.address, owner.address, ether("10"))).to.be.revertedWith("Not special address");
//     //     });

//     //     it("Special address", async function () {
//     //         expect(await token.connect(owner).transfer(nft.address, ether("100")));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("100"));
//     //         expect(await nft.connect(owner).withdrawTokensERC20(token.address, user1.address, ether("10")));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("90"));
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("510"));

//     //         expect(await nft.connect(owner).withdrawTokensERC20(token.address, user1.address, ether("0")));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("0"));
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("600"));

//     //         expect(await token.connect(owner).transfer(nft.address, ether("100")));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("100"));
//     //         expect(await nft.connect(owner).withdrawTokensERC20(token.address, user1.address, ether("1000")));
//     //         expect(await token.connect(owner).balanceOf(nft.address)).to.equal(ether("0"));
//     //         expect(await token.connect(user1).balanceOf(user1.address)).to.equal(ether("700"));
//     //     });
//     // });

// });
