const Wallet = artifacts.require("Wallet");
const Token = artifacts.require("Token");
const PriceConsumerV3 = artifacts.require("PriceConsumerV3");

const ethUsdContract = "0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419";
const azukiPriceContract = "0xa8b9a447c73191744d5b79bce864f343455e1150";

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(Wallet, ethUsdContract, azukiPriceContract);
  const wallet = await Wallet.deployed();
  console.log("Wallet deployed @: " + wallet.address);

  await deployer.deploy(Token, "MasterZ Dev Token", "MDT", 1000000);
  const token = await Token.deployed();
  console.log("Token deployed @: " + token.address);

  await deployer.deploy(PriceConsumerV3, ethUsdContract);
  const ethUsdPrice = await PriceConsumerV3.deployed();
  console.log("ethUsdPrice deployed @: " + ethUsdPrice.address);

  /*await deployer.deploy(PriceConsumerV3, azukiPriceContract);
  const azukiUsdPrice = await PriceConsumerV3.deployed();
  console.log("azukiUsdPrice deployed @: " + azukiUsdPrice.address);*/
};
