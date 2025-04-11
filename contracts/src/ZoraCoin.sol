// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ZoraCoin
 * @dev ERC20 token with metadata URI support and mint/burn capabilities
 */
contract ZoraCoin is ERC20, Ownable {
    string private _metadataUri;
    uint256 private _totalSupply;

    event MetadataURIUpdated(string newURI);
    event TokensBurned(address indexed burner, uint256 amount);

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
            _totalSupply += initialAmounts[i];
        }
    }

    /**
     * @dev Returns the metadata URI for the token
     */
    function getMetadataURI() public view returns (string memory) {
        return _metadataUri;
    }

    /**
     * @dev Updates the metadata URI for the token
     * @param newMetadataURI The new metadata URI
     */
    function updateMetadataURI(string memory newMetadataURI) public onlyOwner {
        _metadataUri = newMetadataURI;
        emit MetadataURIUpdated(newMetadataURI);
    }

    /**
     * @dev Returns the total supply of tokens
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Mints new tokens to the specified address
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        _totalSupply += amount;
    }

    /**
     * @dev Burns tokens from the caller's balance
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        _totalSupply -= amount;
        emit TokensBurned(msg.sender, amount);
    }
}

/**
 * @title ZoraCoinFactory
 * @dev Factory contract for creating ZoraCoin tokens
 */
contract ZoraCoinFactory {
    event CoinCreated(
        address indexed creator,
        address indexed coinAddress,
        string name,
        string symbol
    );

    /**
     * @dev Creates a new ZoraCoin token
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param owner The address that will own the token
     * @param metadataUri The URI pointing to the token's metadata
     * @param initialReceivers Array of addresses to receive initial tokens
     * @param initialAmounts Array of amounts to mint to each receiver
     * @return The address of the newly created token
     */
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
