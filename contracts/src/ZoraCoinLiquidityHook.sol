// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/contracts/libraries/PoolKey.sol";
import "@uniswap/v4-core/contracts/libraries/PoolId.sol";

/**
 * @title ZoraCoinLiquidityHook
 * @dev Implements Uniswap v4 hooks for ZoraCoin liquidity management
 */
contract ZoraCoinLiquidityHook {
    // Mapping to track which pools are managed by this hook
    mapping(bytes32 => bool) public managedPools;
    
    // Mapping to track initial liquidity providers
    mapping(bytes32 => address) public initialLiquidityProviders;

    event PoolInitialized(bytes32 indexed poolId, address token0, address token1);
    event LiquidityAdded(bytes32 indexed poolId, address provider, uint256 amount0, uint256 amount1);

    /**
     * @dev Hook called before pool initialization
     */
    function beforeInitialize(
        address sender,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        bytes calldata hookData
    ) external returns (bytes4) {
        bytes32 poolId = PoolId.toId(key);
        require(!managedPools[poolId], "Pool already initialized");
        managedPools[poolId] = true;
        initialLiquidityProviders[poolId] = sender;
        
        emit PoolInitialized(poolId, key.token0, key.token1);
        return this.beforeInitialize.selector;
    }

    /**
     * @dev Hook called after pool initialization
     */
    function afterInitialize(
        address sender,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick,
        bytes calldata hookData
    ) external returns (bytes4) {
        return this.afterInitialize.selector;
    }

    /**
     * @dev Hook called before adding liquidity
     */
    function beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4) {
        bytes32 poolId = PoolId.toId(key);
        require(managedPools[poolId], "Pool not managed by this hook");
        
        emit LiquidityAdded(
            poolId,
            sender,
            params.liquidityDelta,
            params.liquidityDelta
        );
        
        return this.beforeAddLiquidity.selector;
    }

    /**
     * @dev Returns whether a pool is managed by this hook
     */
    function isManagedPool(bytes32 poolId) external view returns (bool) {
        return managedPools[poolId];
    }

    /**
     * @dev Returns the initial liquidity provider for a pool
     */
    function getInitialLiquidityProvider(bytes32 poolId) external view returns (address) {
        return initialLiquidityProviders[poolId];
    }
} 