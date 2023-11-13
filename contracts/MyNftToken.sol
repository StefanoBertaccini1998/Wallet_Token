// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNftToken is
    ERC721,
    ERC721Pausable,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint public unlockTime;
    address public factoryAddress;

    uint256 public immutable hardCap;

    error notAnOwnerOrFactory();
    error maxSupplyReached();

    event Withdrawal(uint amount, uint when);

    constructor(
        string memory collName,
        string memory collSym
    ) ERC721(collName, collSym) {
        factoryAddress = msg.sender;
        hardCap = 4;
    }

    modifier onlyFactory() {
        if (msg.sender != factoryAddress) {
            revert notAnOwnerOrFactory();
        }
        //require(msg.sender == factoryAddress, "Not the token factory");
        _;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmb27L7Zr1853xV3rC7Z9mSQ1KTF7NJQnEDdinLNPKH71V/";
    }

    function mint(address to) public onlyOwner {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        //require(tokenId < hardCap, "Max supply reached");
        if (tokenId >= hardCap) {
            revert maxSupplyReached();
        }
        _safeMint(to, tokenId);
        string memory uri = string.concat(Strings.toString(tokenId), ".json");
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function pause() external onlyFactory {
        _pause();
    }

    function unpause() external onlyFactory {
        _unpause();
    }
}
