# Model Context Protocol: Zora Coin Launcher Platform

## 1. Project Overview

A decentralized platform for launching custom tokens on the Zora network with IPFS-based metadata storage and potential Uniswap v4 integration for immediate liquidity provisions.

### 1.1 Core Functionality
- Create and deploy customized ERC20 tokens using Zora Coin SDK
- Upload and pin images to IPFS for token metadata
- Generate and store token metadata on IPFS
- Support wallet connection for transaction signing
- Monitor transaction status and provide feedback
- Optional liquidity pool creation using Uniswap v4 hooks

## 2. Architecture Components

### 2.1 Frontend Components
- **TokenCreationForm**: Main user interface for token creation
- **ImageUploader**: Component for handling image uploads and previews
- **WalletConnector**: Interface for connecting various wallets
- **TransactionMonitor**: Display component for transaction status
- **TokenDashboard**: Overview of created tokens and their statuses

### 2.2 Backend Services
- **IPFS Service**: Handle image and metadata uploads to IPFS
- **Token Deployment Service**: Interface with Zora SDK for token creation
- **Transaction Monitoring Service**: Track on-chain transactions
- **Authentication Service**: Handle user authentication and permissions
- **Analytics Service**: Track usage and performance metrics

### 2.3 Smart Contract Interfaces
- **Zora Coin Factory Interface**: For deploying new token contracts
- **Zora Coin Interface**: For interacting with deployed tokens
- **Uniswap v4 Hook Interface**: For creating liquidity pools (optional)

## 3. Data Models

### 3.1 Token Model
```typescript
interface TokenData {
  name: string;                // Token name
  symbol: string;              // Token ticker symbol
  imageUri: string;            // IPFS URI for token image
  metadataUri: string;         // IPFS URI for complete metadata
  description?: string;        // Optional token description
  ownerAddress: string;        // Creator's wallet address
  contractAddress?: string;    // Deployed token contract address
  transactionHash?: string;    // Deployment transaction hash
  createdAt: Date;             // Creation timestamp
  deployedAt?: Date;           // Deployment timestamp
  status: 'pending' | 'deployed' | 'failed'; // Token status
}
```

### 3.2 Image Upload Model
```typescript
interface ImageUpload {
  originalName: string;        // Original filename
  mimeType: string;            // File MIME type
  size: number;                // File size in bytes
  buffer: Buffer;              // Raw file data
  ipfsHash?: string;           // IPFS CID after upload
  ipfsUri?: string;            // Complete IPFS URI
  createdAt: Date;             // Upload timestamp
}
```

### 3.3 Transaction Model
```typescript
interface Transaction {
  id: string;                  // Transaction ID
  type: 'token_creation' | 'liquidity_addition'; // Transaction type
  hash?: string;               // On-chain transaction hash
  status: 'pending' | 'confirmed' | 'failed'; // Transaction status
  fromAddress: string;         // Sender wallet address
  nonce?: number;              // Transaction nonce
  gasPrice?: string;           // Gas price in wei
  gasLimit?: string;           // Gas limit
  value?: string;              // Transaction value
  data?: string;               // Transaction data
  blockNumber?: number;        // Block number once confirmed
  createdAt: Date;             // Creation timestamp
  updatedAt: Date;             // Last update timestamp
}
```

## 4. API Endpoints

### 4.1 Authentication Endpoints
- `POST /api/auth/login`: User login
- `POST /api/auth/logout`: User logout
- `GET /api/auth/me`: Get current user

### 4.2 Image Upload Endpoints
- `POST /api/upload`: Upload an image to IPFS
- `GET /api/upload/:ipfsHash`: Retrieve image metadata by IPFS hash

### 4.3 Token Creation Endpoints
- `POST /api/tokens`: Create a new token
- `GET /api/tokens`: List all tokens created by user
- `GET /api/tokens/:contractAddress`: Get token details by address
- `GET /api/tokens/status/:transactionHash`: Check token creation status

### 4.4 Liquidity Pool Endpoints (Optional)
- `POST /api/liquidity`: Create a liquidity pool on Uniswap v4
- `GET /api/liquidity/:tokenAddress`: Get liquidity pool details

## 5. Smart Contract Integration

### 5.1 Zora Coin Factory Interface
```solidity
interface ZoraCoinFactory {
    function createCoin(
        string memory name,
        string memory symbol,
        address minter,
        string memory metadataURI,
        address[] memory initialReceivers,
        uint256[] memory initialAmounts
    ) external returns (address);
    
    function getCoins() external view returns (address[] memory);
    function getCoinsByCreator(address creator) external view returns (address[] memory);
}
```

### 5.2 Zora Coin Interface
```solidity
interface ZoraCoin {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function getMetadataURI() external view returns (string memory);
    function updateMetadataURI(string memory newMetadataURI) external;
}
```

### 5.3 Uniswap v4 Hook Interface (Optional)
```solidity
interface IHooks {
    function beforeInitialize(
        address sender,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        bytes calldata hookData
    ) external returns (bytes4);

    function afterInitialize(
        address sender,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick,
        bytes calldata hookData
    ) external returns (bytes4);

    function beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4);
}
```

## 6. IPFS Integration

### 6.1 IPFS Connection
```javascript
const { create } = require('ipfs-http-client');

// Connection to IPFS
const ipfs = create({
  host: process.env.IPFS_HOST || 'ipfs.infura.io',
  port: process.env.IPFS_PORT || 5001,
  protocol: process.env.IPFS_PROTOCOL || 'https',
  auth: process.env.IPFS_AUTH  // Base64 encoded API key:secret for Infura or Pinata
});
```

### 6.2 Metadata Schema
```json
{
  "name": "Token Name",
  "symbol": "TKN",
  "description": "Description of the token",
  "image": "ipfs://Qm...",
  "created_at": "2025-04-10T12:00:00Z",
  "properties": {
    "creator": "0x...",
    "website": "https://example.com",
    "socials": {
      "twitter": "@handle",
      "discord": "discord_url"
    }
  }
}
```

## 7. Token Creation Flow

1. **Frontend Submission**
   - User connects wallet
   - User fills form with token name, symbol, image
   - Form validation occurs client-side
   - Submit button triggers image upload

2. **Image Processing**
   - Frontend sends image to backend API
   - Backend validates image type and size
   - Image is uploaded to IPFS
   - IPFS URI is returned to frontend

3. **Metadata Creation**
   - Backend generates metadata JSON with image URI
   - Metadata JSON is uploaded to IPFS
   - Metadata URI is stored for token creation

4. **Token Deployment**
   - Backend prepares transaction parameters for Zora Coin Factory
   - User signs transaction via connected wallet
   - Transaction is submitted to blockchain
   - Backend monitors transaction status

5. **Confirmation & Display**
   - Transaction receipt is processed
   - Token details are stored in database
   - User is shown successful creation message
   - Token is displayed in user dashboard

## 8. Zora SDK Integration

### 8.1 SDK Initialization
```javascript
const { ZDK } = require('@zoralabs/zdk');
const { Wallet, providers } = require('ethers');

// Initialize provider and wallet
const provider = new providers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new Wallet(process.env.PRIVATE_KEY, provider);

// Initialize Zora SDK
const zdk = new ZDK({
  wallet,
  network: process.env.NETWORK || 'zora',
});
```

### 8.2 Token Creation Function
```javascript
async function createZoraCoin(name, symbol, metadataURI) {
  try {
    // Prepare transaction
    const transaction = await zdk.coins.createCoin({
      name: name,
      symbol: symbol,
      minter: wallet.address,
      metadataURI: metadataURI,
      initialReceivers: [], // Optional
      initialAmounts: [],   // Optional
    });
    
    // Wait for confirmation
    const receipt = await transaction.wait();
    
    // Extract contract address from events
    // Exact event parsing depends on Zora implementation
    const contractAddress = receipt.events?.filter(
      (e) => e.event === 'CoinCreated'
    )[0]?.args?.coinAddress;
    
    return {
      success: true,
      contractAddress,
      transactionHash: receipt.transactionHash
    };
  } catch (error) {
    console.error('Error creating coin:', error);
    return {
      success: false,
      error: error.message
    };
  }
}
```

## 9. Uniswap v4 Integration (Optional)

### 9.1 Custom Hook Implementation
```solidity
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {BaseHook} from "v4-periphery/BaseHook.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";

contract ZoraTokenHook is BaseHook {
    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHookPermissions() public pure override returns (HookPermissions memory) {
        return HookPermissions({
            beforeInitialize: true,
            afterInitialize: true,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: false,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    function beforeInitialize(
        address sender,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        bytes calldata hookData
    ) external override returns (bytes4) {
        // Custom logic before pool initialization
        return BaseHook.beforeInitialize.selector;
    }

    function afterInitialize(
        address sender,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick,
        bytes calldata hookData
    ) external override returns (bytes4) {
        // Custom logic after pool initialization
        return BaseHook.afterInitialize.selector;
    }

    function beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external override returns (bytes4) {
        // Custom logic before adding liquidity
        return BaseHook.beforeAddLiquidity.selector;
    }
}
```

### 9.2 Liquidity Pool Creation
```javascript
async function createLiquidityPool(tokenAddress, ethAmount) {
  try {
    // Initialize Uniswap v4 interface
    // Note: This would need to be updated with actual Uniswap v4 SDK code
    
    // Deploy hook if needed
    // const hookFactory = new ethers.ContractFactory(ZoraTokenHookABI, ZoraTokenHookBytecode, wallet);
    // const hook = await hookFactory.deploy(poolManagerAddress);
    
    // Create pool with the hook
    // const poolCreationTx = await poolManager.initialize(
    //   {
    //     token0: tokenAddress < WETH_ADDRESS ? tokenAddress : WETH_ADDRESS,
    //     token1: tokenAddress < WETH_ADDRESS ? WETH_ADDRESS : tokenAddress,
    //     fee: 3000, // 0.3%
    //     hookAddress: hook.address,
    //     hooks: customHookData
    //   },
    //   sqrtPriceX96
    // );
    
    // const receipt = await poolCreationTx.wait();
    
    return {
      success: true,
      // poolAddress: extractPoolAddress(receipt),
      // hookAddress: hook.address,
      // transactionHash: receipt.transactionHash
    };
  } catch (error) {
    console.error('Error creating liquidity pool:', error);
    return {
      success: false,
      error: error.message
    };
  }
}
```

## 10. Environment Configuration

### 10.1 Required Environment Variables
```
# Server Configuration
PORT=3001
NODE_ENV=development

# Blockchain Configuration
RPC_URL=https://rpc.zora.energy
NETWORK=zora
CHAIN_ID=7777777
PRIVATE_KEY=your_private_key_for_backend_operations

# IPFS Configuration
IPFS_HOST=ipfs.infura.io
IPFS_PORT=5001
IPFS_PROTOCOL=https
IPFS_PROJECT_ID=your_infura_project_id
IPFS_PROJECT_SECRET=your_infura_project_secret

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=zora_launcher
DB_USER=postgres
DB_PASSWORD=password

# Security
JWT_SECRET=your_jwt_secret
API_RATE_LIMIT=100
```

### 10.2 Frontend Environment Variables
```
NEXT_PUBLIC_API_URL=http://localhost:3001/api
NEXT_PUBLIC_IPFS_GATEWAY=https://ipfs.io/ipfs/
NEXT_PUBLIC_CHAIN_ID=7777777
NEXT_PUBLIC_NETWORK_NAME=Zora
NEXT_PUBLIC_BLOCK_EXPLORER=https://explorer.zora.energy
```

## 11. Deployment Strategy

### 11.1 Backend Deployment
- Node.js application deployed on AWS EC2 or equivalent
- PM2 for process management
- NGINX as reverse proxy
- SSL certification via Let's Encrypt
- Docker containerization for consistent environments

### 11.2 Frontend Deployment
- Next.js application deployed on Vercel or Netlify
- Environment variables configured in platform
- Continuous deployment from GitHub repository

### 11.3 Smart Contract Deployment
- Hardhat or Foundry for contract compilation and deployment
- Multi-sig wallet for contract ownership (recommended)
- Deployment scripts for various environments

## 12. Security Considerations

### 12.1 Smart Contract Security
- Automated testing with high coverage
- Static analysis using tools like Slither
- Consider formal verification for critical functions
- External audit before production launch

### 12.2 API Security
- Rate limiting to prevent abuse
- JWT authentication for protected endpoints
- Input validation and sanitization
- CORS configuration
- Helmet.js for HTTP security headers

### 12.3 Frontend Security
- CSP (Content Security Policy) implementation
- SRI (Subresource Integrity) for external scripts
- Regular dependency audits
- Avoiding storage of sensitive information in localStorage

## 13. Monitoring and Analytics

### 13.1 Backend Monitoring
- Prometheus for metrics collection
- Grafana for visualization
- Winston for structured logging
- Sentry for error tracking

### 13.2 Smart Contract Monitoring
- Events indexing for important contract actions
- Gas usage monitoring
- Etherscan/Zorascan verification and monitoring

### 13.3 User Analytics
- Basic analytics for user actions
- Conversion funnel tracking
- Error rate monitoring
