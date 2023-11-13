const {
  BN,
  constants,
  expectEvent,
  expectRevert,
  time,
} = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const { ZERO_ADDRESS } = constants;
const { expect } = require("chai");

const Token = artifacts.require("Token");
const Wallet = artifacts.require("Wallet");
const PriceConsumerV3 = artifacts.require("PriceConsumerV3");
const AggregatorProxy = artifacts.require("AggregatorProxy");

const fromWei = (x) => web3.utils.fromWei(x.toString());
const toWei = (x) => web3.utils.toWei(x.toString());
const fromWei6Dec = (x) => Number(x) / Math.pow(10, 6);
const toWei6Dec = (x) => Number(x) * Math.pow(10, 6);
const fromWei8Dec = (x) => Number(x) / Math.pow(10, 8);
const toWei8Dec = (x) => Number(x) * Math.pow(10, 8);
const fromWei2Dec = (x) => Number(x) / Math.pow(10, 2);
const toWei2Dec = (x) => Number(x) * Math.pow(10, 2);

const ethUsdContract = "0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419";
const azukiPriceContract = "0xa8b9a447c73191744d5b79bce864f343455e1150";

contract("Wallet", function (accounts) {
  const [deployer, firstAccount, secondAccount, fakeOwner] = accounts;

  it("retrieve deployed contracts", async function () {
    tokenContract = await Token.deployed();
    expect(tokenContract.address).to.be.not.equal(ZERO_ADDRESS);
    expect(tokenContract.address).to.match(/0x[0-9a-fA-F]{40}/);

    walletContract = await Wallet.deployed();
    priceEthUsd = await PriceConsumerV3.deployed();
  });

  it("distribute some tokens from deployer", async function () {
    await tokenContract.transfer(firstAccount, toWei(100000));
    await tokenContract.transfer(secondAccount, toWei(150000));

    balDepl = await tokenContract.balanceOf(deployer);
    balFA = await tokenContract.balanceOf(firstAccount);
    balSA = await tokenContract.balanceOf(secondAccount);

    console.log(fromWei(balDepl), fromWei(balFA), fromWei(balSA));
  });

  it("Eth / Usd price", async function () {
    ret = await priceEthUsd.getPriceDecimals();
    console.log(ret.toString());
    res = await priceEthUsd.getLatestPrice();
    console.log(fromWei8Dec(res));
  });

  it("Azuki / Eth price", async function () {
    azukiUsdData = await AggregatorProxy.at(azukiPriceContract);
    ret = await azukiUsdData.decimals();
    console.log(ret.toString());
    res = await azukiUsdData.latestRoundData();
    console.log(fromWei(res[1]));
    console.log(fromWei(await walletContract.getNFTPrice()));
  });

  it("Convert Eth  to Usd ", async function () {
    await walletContract.sendTransaction({
      from: firstAccount,
      value: toWei(2),
    });

    ret = await walletContract.convertEthInUsd(firstAccount);
    console.log(fromWei2Dec(ret));

    rec = await walletContract.convertUsdInEth(toWei2Dec(5000));
    console.log(fromWei(rec));

    rep = await walletContract.convertNFTPriceInUsd();
    console.log(fromWei2Dec(rep));

    res = await walletContract.convertUsdInNFTAmount(toWei2Dec(5000));
    console.log(res[0].toString(), fromWei2Dec(res[1]));

    rel = await walletContract.convertUsdInNFTAmount(toWei2Dec(8000));
    console.log(rel[0].toString(), fromWei2Dec(rel[1]));
  });
});
