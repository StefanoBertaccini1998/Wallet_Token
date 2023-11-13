// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PriceConsumer.sol";

contract Wallet is Ownable {
    uint public constant usdDecimals = 2;
    uint public constant nftDecimals = 18;
    uint public nftPrice; // In ETH
    uint public ownerEthAmountToWithdraw;
    uint public ownerTokenAmountToWithdraw;

    address public oracleEthUsdPrice;
    address public oracleTokenEthPrice;

    PriceConsumerV3 public ethUsdContract;
    PriceConsumerV3 public tokenEthContract;

    mapping(address => uint256) public userEthDeposits;
    mapping(address => mapping(address => uint256)) public userTokenDeposits;

    constructor(address clEthUsd, address clTokenUsd) {
        oracleEthUsdPrice = clEthUsd;
        oracleTokenEthPrice = clTokenUsd;

        ethUsdContract = new PriceConsumerV3(oracleEthUsdPrice);
        tokenEthContract = new PriceConsumerV3(oracleTokenEthPrice);
    }

    receive() external payable {
        registerUserDeposit(msg.sender, msg.value);
    }

    function registerUserDeposit(address sender, uint256 value) internal {
        userEthDeposits[sender] += value;
    }

    function getNFTPrice() external view returns (uint256) {
        AggregatorV3Interface nftOraclePrice = AggregatorV3Interface(
            oracleTokenEthPrice
        );
        (, int iPrice, , , ) = nftOraclePrice.latestRoundData();
        uint256 price = uint256(iPrice);
        return price;
    }

    function convertEthInUsd(address user) public view returns (uint) {
        uint ethPriceDecimals = ethUsdContract.getPriceDecimals(); // 8 decimals
        uint ethPrice = uint(ethUsdContract.getLatestPrice()); // scaled by 10^8
        uint divDecs = 18 + ethPriceDecimals - usdDecimals;
        uint userUsdDeposit = (userEthDeposits[user] * ethPrice) /
            (10 ** divDecs); /* scaled by 10^26 / 10^24*/
        return userUsdDeposit;
    }

    function convertUsdInEth(uint usdAmount) public view returns (uint) {
        uint ethPriceDecimals = ethUsdContract.getPriceDecimals();
        uint ethPrice = uint(ethUsdContract.getLatestPrice());
        uint mulDecs = 18 + ethPriceDecimals - usdDecimals;
        uint convertAmountInEth = (usdAmount * (10 ** mulDecs)) / ethPrice;
        return convertAmountInEth;
    }

    function transferEthAmountOnBuy(uint nftNumber) public {
        uint calcTotalUsdAmount = nftPrice * nftNumber * (10 ** 2);
        uint ethAmountForBuying = convertUsdInEth(calcTotalUsdAmount);
        require(
            userEthDeposits[msg.sender] >= ethAmountForBuying,
            "Not enough deposits by the user"
        );
        ownerEthAmountToWithdraw += ethAmountForBuying;
        userEthDeposits[msg.sender] -= ethAmountForBuying;
    }

    function userDeposit(address token, uint256 amount) external {
        SafeERC20.safeTransferFrom(
            IERC20(token),
            msg.sender,
            address(this),
            amount
        );
        userTokenDeposits[msg.sender][token] += amount;
    }

    function convertNFTPriceInUsd() public view returns (uint) {
        uint tokenPriceDecimals = tokenEthContract.getPriceDecimals(); //18
        uint tokenPrice = uint(tokenEthContract.getLatestPrice());

        uint ethPriceDecimals = ethUsdContract.getPriceDecimals();
        uint ethPrice = uint(ethUsdContract.getLatestPrice()); //8

        uint divDecs = ethPriceDecimals + tokenPriceDecimals - usdDecimals;
        uint tokenUsdPrice = (tokenPrice * ethPrice) / (10 ** divDecs);
        return tokenUsdPrice;
    }

    function convertUsdInNFTAmount(
        uint usdAmount
    ) public view returns (uint, uint) {
        uint tokenPriceDecimals = tokenEthContract.getPriceDecimals(); //18
        uint tokenPrice = uint(tokenEthContract.getLatestPrice());

        uint ethPriceDecimals = ethUsdContract.getPriceDecimals(); //8
        uint ethPrice = uint(ethUsdContract.getLatestPrice());

        uint mulDecs = ethPriceDecimals + tokenPriceDecimals - usdDecimals; //24

        uint convertAmountInEth = (usdAmount * (10 ** mulDecs)) / ethPrice;
        uint convertEthInTokens = convertAmountInEth /* *
            (10 ** tokenPriceDecimals) */ /
                tokenPrice;
        uint totalCosts = (convertEthInTokens * tokenPrice * ethPrice) /
            (10 ** mulDecs);
        uint quote = usdAmount - totalCosts;
        return (convertEthInTokens, quote);
    }

    /*function transferTokenAmountOnBuy(address token, uint nftNumber) public {
        uint calcTotalUsdAmount = nftPrice * nftNumber * (10 ** 2);
        uint tokenAmountForBuying = convertUsdInNFTAmount(calcTotalUsdAmount);
        require(
            userTokenDeposits[msg.sender][token] >= tokenAmountForBuying,
            "not enough deposits by the user"
        );
        ownerTokenAmountToWithdraw += tokenAmountForBuying;
        userTokenDeposits[msg.sender][token] -= tokenAmountForBuying;
    }*/

    function getNativeCoinsBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address _token) external view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function nativeCoinsWithdraw() external onlyOwner {
        require(ownerEthAmountToWithdraw > 0, "no eth to withdraw");
        uint256 tmpAmount = ownerEthAmountToWithdraw;
        ownerEthAmountToWithdraw = 0;
        (bool sent, ) = payable(_msgSender()).call{value: tmpAmount}("");
        require(sent, "!sent");
    }

    function nativeEthWithdraw() external {
        require(ownerEthAmountToWithdraw > 0, "no eth to withdraw");
        uint256 tmpAmount = ownerEthAmountToWithdraw;
        ownerEthAmountToWithdraw = 0;
        (bool sent, ) = payable(_msgSender()).call{value: tmpAmount}("");
        require(sent, "!sent");
    }
}
