// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ZoraCoin.sol";
import "./ZoraCoinLiquidityHook.sol";
import "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/contracts/libraries/PoolKey.sol";

/**
 * @title ZoraCoinFactory
 * @dev Factory contract for creating and managing ZoraCoin tokens with Uniswap v4 liquidity support
 */
contract ZoraCoinFactory {
    // Array of all created coins
    address[] private _allCoins;
    
    // Mapping from creator to their created coins
    mapping(address => address[]) private _creatorCoins;

    // Uniswap v4 Pool Manager
    IPoolManager public immutable poolManager;
    
    // Liquidity Hook contract
    ZoraCoinLiquidityHook public immutable liquidityHook;

    event CoinCreated(
        address indexed creator,
        address indexed coinAddress,
        string name,
        string symbol
    );

    event LiquidityPoolCreated(
        address indexed token,
        address indexed pairedToken,
        bytes32 poolId
    );

    constructor(address _poolManager) {
        poolManager = IPoolManager(_poolManager);
        liquidityHook = new ZoraCoinLiquidityHook();
    }

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

        address coinAddress = address(newCoin);
        _allCoins.push(coinAddress);
        _creatorCoins[msg.sender].push(coinAddress);

        emit CoinCreated(msg.sender, coinAddress, name, symbol);
        return coinAddress;
    }

    /**
     * @dev Creates a liquidity pool for a ZoraCoin token
     * @param token The ZoraCoin token address
     * @param pairedToken The token to pair with (e.g., WETH)
     * @param fee The pool fee in basis points
     * @param tickSpacing The tick spacing for the pool
     * @return poolId The ID of the created pool
     */
    function createLiquidityPool(
        address token,
        address pairedToken,
        uint24 fee,
        int24 tickSpacing
    ) public returns (bytes32 poolId) {
        PoolKey memory key = PoolKey({
            token0: token < pairedToken ? token : pairedToken,
            token1: token < pairedToken ? pairedToken : token,
            fee: fee,
            tickSpacing: tickSpacing,
            hooks: address(liquidityHook)
        });

        poolId = poolManager.initialize(key, 0, new bytes(0));
        
        emit LiquidityPoolCreated(token, pairedToken, poolId);
        return poolId;
    }

    /**
     * @dev Returns all created coins
     * @return Array of coin addresses
     */
    function getCoins() public view returns (address[] memory) {
        return _allCoins;
    }

    /**
     * @dev Returns all coins created by a specific creator
     * @param creator The address of the creator
     * @return Array of coin addresses created by the specified creator
     */
    function getCoinsByCreator(address creator) public view returns (address[] memory) {
        return _creatorCoins[creator];
    }

    /**
     * @dev Returns the number of coins created by a specific creator
     * @param creator The address of the creator
     * @return The number of coins created by the specified creator
     */
    function getCreatorCoinCount(address creator) public view returns (uint256) {
        return _creatorCoins[creator].length;
    }

    /**
     * @dev Returns the total number of coins created
     * @return The total number of coins created
     */
    function getTotalCoinCount() public view returns (uint256) {
        return _allCoins.length;
    }
}
