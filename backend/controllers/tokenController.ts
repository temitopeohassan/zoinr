import { Request, Response } from 'express';
import { ethers } from 'ethers';
import { Token } from '../models/Token';
import { Transaction } from '../models/Transaction';
import { ImageUpload } from '../models/ImageUpload';
import { ZoraCoinFactoryABI } from '../contracts/ZoraCoinFactory';
import { create as createIPFSClient } from 'ipfs-http-client';

// Extend Express Request type
declare module 'express' {
  interface Request {
    ipfs: ReturnType<typeof createIPFSClient>;
    provider: ethers.JsonRpcProvider;
    user: {
      address: string;
    };
  }
}

export const createToken = async (req: Request, res: Response) => {
  try {
    const {
      name,
      symbol,
      description,
      imageId,
      initialReceivers,
      initialAmounts
    } = req.body;

    // Validate input
    if (!name || !symbol || !imageId) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Get image from database
    const image = await ImageUpload.findById(imageId);
    if (!image) {
      return res.status(404).json({ message: 'Image not found' });
    }

    // Create metadata
    const metadata = {
      name,
      symbol,
      description,
      image: image.ipfsUri,
      created_at: new Date().toISOString(),
      properties: {
        creator: req.user.address,
      }
    };

    // Upload metadata to IPFS
    const metadataBuffer = Buffer.from(JSON.stringify(metadata));
    const metadataResult = await req.ipfs.add(metadataBuffer);
    const metadataUri = `ipfs://${metadataResult.path}`;

    // Create token record
    const token = new Token({
      name,
      symbol,
      imageUri: image.ipfsUri,
      metadataUri,
      description,
      ownerAddress: req.user.address,
      status: 'pending'
    });
    await token.save();

    // Prepare contract interaction
    const factory = new ethers.Contract(
      process.env.ZORA_FACTORY_ADDRESS!,
      ZoraCoinFactoryABI,
      req.provider
    );

    // Create transaction record
    const transaction = new Transaction({
      id: ethers.hexlify(ethers.randomBytes(32)),
      type: 'token_creation',
      status: 'pending',
      fromAddress: req.user.address,
      data: factory.interface.encodeFunctionData('createCoin', [
        name,
        symbol,
        req.user.address,
        metadataUri,
        initialReceivers || [],
        initialAmounts || []
      ])
    });
    await transaction.save();

    // Return data needed for frontend to complete transaction
    res.status(201).json({
      token: token.toJSON(),
      transaction: {
        to: process.env.ZORA_FACTORY_ADDRESS,
        data: transaction.data,
        id: transaction.id
      }
    });
  } catch (error) {
    console.error('Token creation error:', error);
    res.status(500).json({ message: 'Token creation failed' });
  }
};

export const getTokens = async (req: Request, res: Response) => {
  try {
    const tokens = await Token.find({ ownerAddress: req.user.address })
      .sort({ createdAt: -1 });
    res.json(tokens);
  } catch (error) {
    console.error('Get tokens error:', error);
    res.status(500).json({ message: 'Failed to fetch tokens' });
  }
};

export const getToken = async (req: Request, res: Response) => {
  try {
    const token = await Token.findOne({
      contractAddress: req.params.address.toLowerCase()
    });
    if (!token) {
      return res.status(404).json({ message: 'Token not found' });
    }
    res.json(token);
  } catch (error) {
    console.error('Get token error:', error);
    res.status(500).json({ message: 'Failed to fetch token' });
  }
};

export const updateTokenStatus = async (req: Request, res: Response) => {
  try {
    const { transactionId, transactionHash, status } = req.body;

    const transaction = await Transaction.findOne({ id: transactionId });
    if (!transaction) {
      return res.status(404).json({ message: 'Transaction not found' });
    }

    // Update transaction
    transaction.hash = transactionHash;
    transaction.status = status;
    if (status === 'confirmed') {
      const receipt = await req.provider.getTransactionReceipt(transactionHash);
      if (!receipt) {
        return res.status(400).json({ message: 'Transaction receipt not found' });
      }
      transaction.blockNumber = receipt.blockNumber;
      
      // Get deployed token address from logs
      const factory = new ethers.Contract(
        process.env.ZORA_FACTORY_ADDRESS!,
        ZoraCoinFactoryABI,
        req.provider
      );
      const event = receipt.logs
        .map(log => {
          try {
            return factory.interface.parseLog(log);
          } catch (e) {
            return null;
          }
        })
        .find(event => event && event.name === 'CoinCreated');
      
      if (event) {
        // Update token record
        const token = await Token.findOne({ 
          ownerAddress: transaction.fromAddress,
          status: 'pending'
        }).sort({ createdAt: -1 });
        
        if (token) {
          token.contractAddress = event.args.coinAddress;
          token.transactionHash = transactionHash;
          token.status = 'deployed';
          token.deployedAt = new Date();
          await token.save();
        }
      }
    }
    await transaction.save();

    res.json({ message: 'Status updated successfully' });
  } catch (error) {
    console.error('Update token status error:', error);
    res.status(500).json({ message: 'Failed to update status' });
  }
}; 