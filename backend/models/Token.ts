import mongoose, { Document, Schema } from 'mongoose';

export interface IToken extends Document {
  name: string;
  symbol: string;
  imageUri: string;
  metadataUri: string;
  description?: string;
  ownerAddress: string;
  contractAddress?: string;
  transactionHash?: string;
  createdAt: Date;
  deployedAt?: Date;
  status: 'pending' | 'deployed' | 'failed';
}

const TokenSchema = new Schema<IToken>({
  name: {
    type: String,
    required: true,
    trim: true
  },
  symbol: {
    type: String,
    required: true,
    trim: true,
    uppercase: true
  },
  imageUri: {
    type: String,
    required: true
  },
  metadataUri: {
    type: String,
    required: true
  },
  description: {
    type: String,
    trim: true
  },
  ownerAddress: {
    type: String,
    required: true,
    lowercase: true
  },
  contractAddress: {
    type: String,
    lowercase: true,
    sparse: true,
    index: true
  },
  transactionHash: {
    type: String,
    lowercase: true,
    sparse: true,
    index: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  deployedAt: {
    type: Date
  },
  status: {
    type: String,
    enum: ['pending', 'deployed', 'failed'],
    default: 'pending'
  }
}, {
  timestamps: true
});

// Indexes for common queries
TokenSchema.index({ ownerAddress: 1, createdAt: -1 });
TokenSchema.index({ status: 1 });

export const Token = mongoose.model<IToken>('Token', TokenSchema); 