// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZoraCoin is ERC20, Ownable {
    string private _metadataUri;

    constructor(
        string memory name,
        string memory symbol,
        address owner,
        string memory metadataUri,
        address[] memory initialReceivers,
        uint256[] memory initialAmounts
    ) ERC20(name, symbol) {
        _metadataUri = metadataUri;
        _transferOwnership(owner);

        require(initialReceivers.length == initialAmounts.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < initialReceivers.length; i++) {
            _mint(initialReceivers[i], initialAmounts[i]);
        }
    }

    function metadataUri() public view returns (string memory) {
        return _metadataUri;
    }
}

contract ZoraCoinFactory {
    event CoinCreated(
        address indexed creator,
        address indexed coinAddress,
        string name,
        string symbol
    );

    function createCoin(
        string memory name,
        string memory symbol,
        address owner,
        string memory metadataUri,
        address[] memory initialReceivers,
        uint256[] memory initialAmounts
    ) public returns (address) {
        ZoraCoin newCoin = new ZoraCoin(
            name,
            symbol,
            owner,
            metadataUri,
            initialReceivers,
            initialAmounts
        );

        emit CoinCreated(msg.sender, address(newCoin), name, symbol);
        return address(newCoin);
    }
} 