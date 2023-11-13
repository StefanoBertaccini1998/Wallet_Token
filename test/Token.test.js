const {
  BN,
  constants,
  excepctEvent,
  expectRevert,
  time,
  balance,
} = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const { ZERO_ADDRES } = constants;

const { expect } = require("chai");

const Token = artifacts.require("Token");

contract("Token test", (accounts) => {
  /* 0x67B5E7eE2823d0e79bCD6E57Ae191A5A7726A96A (1000 ETH)
(1) 0x67D744F6E1270D90Cfbb894A9E4e01948645628B (1000 ETH)
(2) 0xa81c3A4c4E1C05aFDf0FddC81F3501B57AE5E852 (1000 ETH)
(3) 0xC30A999a29c8F780755FdFE1Ba951b303Da59421 (1000 ETH)
(4) 0xb2C6BfdcC33CE0178f6f7eeE3949DAf1dad7382e (1000 ETH)
(5) 0x1EB40723A301F38Fc8371f6B53bee0F85271ad75 (1000 ETH)
(6) 0x03DaBeC9c038f054e3f4A42e25D18fE4F2d5c78C (1000 ETH)
(7) 0x88627328Cc65db94303c19c782C51d831F67f859 (1000 ETH)
(8) 0xb40D9246E0c20932ae181c035e019234771D2285 (1000 ETH)
(9) 0xB020D731b501B16BAb58e24F1e4bb134F61582b0 (1000 ETH)*/
  const [deployer, firstAccount, secondAccount, thirdAccount, fourthAccount] =
    accounts;

  //beforeEach(async () => {
  //  this.token = await Token.new("Test1", "TT1");
  //});

  it("deployed", async () => {
    this.token = await Token.deployed();
    expect(this.token.address).to.not.equal(ZERO_ADDRES);
    expect(this.token.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log("new Token address: " + this.token.address);

    console.log("Toke owner: " + (await this.token.owner()));
  });

  it("transfer1", async () => {
    balanceSc = await this.token.balanceOf(secondAccount);
    console.log("SC " + web3.utils.fromWei(balanceSc));

    await this.token.mint(firstAccount, web3.utils.toWei("50"), {
      from: deployer,
    });

    await this.token.mint(secondAccount, web3.utils.toWei("100"), {
      from: deployer,
    });
    balanceSc = await this.token.balanceOf(secondAccount);
    console.log("SC " + web3.utils.fromWei(balanceSc));

    await this.token.mint(deployer, web3.utils.toWei("200"), {
      from: deployer,
    });
    balanceOw = await this.token.balanceOf(deployer);
    console.log("OW " + web3.utils.fromWei(balanceOw));

    await this.token.transfer(secondAccount, web3.utils.toWei("10"), {
      from: deployer,
    });
    balanceSc = await this.token.balanceOf(secondAccount);
    console.log("SC " + web3.utils.fromWei(balanceSc));
    balanceOw = await this.token.balanceOf(deployer);
    console.log("OW " + web3.utils.fromWei(balanceOw));
  });

  it("transfer2", async () => {
    balanceFa = await this.token.balanceOf(firstAccount);
    console.log("FA " + web3.utils.fromWei(balanceFa));
    balanceFa = await this.token.balanceOf(secondAccount);
    console.log("SC " + web3.utils.fromWei(balanceFa));

    await this.token.transfer(firstAccount, web3.utils.toWei("10"), {
      from: secondAccount,
    });

    balanceSc = await this.token.balanceOf(firstAccount);
    console.log("FA " + web3.utils.fromWei(balanceSc));
    balanceFa = await this.token.balanceOf(secondAccount);
    console.log("SC " + web3.utils.fromWei(balanceFa));
  });

  it("transferFrom", async () => {
    await this.token.approve(secondAccount, web3.utils.toWei("20"), {
      from: firstAccount,
    });
    await this.token.transferFrom(
      firstAccount,
      secondAccount,
      web3.utils.toWei("15"),
      {
        from: secondAccount,
      }
    );
    balanceSc = await this.token.balanceOf(firstAccount);
    console.log("FA " + web3.utils.fromWei(balanceSc));
    balanceFa = await this.token.balanceOf(secondAccount);
    console.log("SC " + web3.utils.fromWei(balanceFa));
  });
});
