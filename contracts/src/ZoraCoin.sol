// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ZoraCoin
 * @dev ERC20 token with metadata URI support and mint/burn capabilities
 * Compatible with Zora SDK and viem clients
 */
contract ZoraCoin is ERC20, Ownable {
    string private _metadataUri;
    address public payoutRecipient;
    address public platformReferrer;
    uint256 public initialPurchaseWei;

    event MetadataURIUpdated(string newURI);
    event TokensBurned(address indexed burner, uint256 amount);
    event PayoutRecipientUpdated(address indexed newRecipient);
    event PlatformReferrerUpdated(address indexed newReferrer);

    constructor(
        string memory name,
        string memory symbol,
        string memory metadataUri,
        address _payoutRecipient,
        address _platformReferrer,
        uint256 _initialPurchaseWei
    ) ERC20(name, symbol) {
        _metadataUri = metadataUri;
        payoutRecipient = _payoutRecipient;
        platformReferrer = _platformReferrer;
        initialPurchaseWei = _initialPurchaseWei;
        _transferOwnership(_payoutRecipient);
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
     * @dev Updates the payout recipient address
     * @param newRecipient The new payout recipient address
     */
    function updatePayoutRecipient(address newRecipient) public onlyOwner {
        require(newRecipient != address(0), "Invalid recipient address");
        payoutRecipient = newRecipient;
        emit PayoutRecipientUpdated(newRecipient);
    }

    /**
     * @dev Updates the platform referrer address
     * @param newReferrer The new platform referrer address
     */
    function updatePlatformReferrer(address newReferrer) public onlyOwner {
        platformReferrer = newReferrer;
        emit PlatformReferrerUpdated(newReferrer);
    }

    /**
     * @dev Mints new tokens to the specified address
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Burns tokens from the caller's balance
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
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
     * @param metadataUri The URI pointing to the token's metadata
     * @param payoutRecipient The address that will receive payouts
     * @param platformReferrer The optional platform referrer address
     * @param initialPurchaseWei The initial purchase amount in Wei
     * @return The address of the newly created token
     */
    function createCoin(
        string memory name,
        string memory symbol,
        string memory metadataUri,
        address payoutRecipient,
        address platformReferrer,
        uint256 initialPurchaseWei
    ) public returns (address) {
        ZoraCoin newCoin = new ZoraCoin(
            name,
            symbol,
            metadataUri,
            payoutRecipient,
            platformReferrer,
            initialPurchaseWei
        );

        emit CoinCreated(msg.sender, address(newCoin), name, symbol);
        return address(newCoin);
    }
}
