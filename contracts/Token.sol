// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 _supply
    ) ERC20(tokenName, tokenSymbol) {
        _mint(msg.sender, _supply * (1e18));
    }

    /* function decimals() public pure override returns (uint8){
        return 8;
    } */

    function mint(address account, uint amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {}
}
