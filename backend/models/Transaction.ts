import mongoose, { Document, Schema } from 'mongoose';

export interface ITransaction extends Document {
  id: string;
  type: 'token_creation' | 'liquidity_addition';
  hash?: string;
  status: 'pending' | 'confirmed' | 'failed';
  fromAddress: string;
  nonce?: number;
  gasPrice?: string;
  gasLimit?: string;
  value?: string;
  data?: string;
  blockNumber?: number;
  createdAt: Date;
  updatedAt: Date;
}

const TransactionSchema = new Schema<ITransaction>({
  id: {
    type: String,
    required: true,
    unique: true
  },
  type: {
    type: String,
    enum: ['token_creation', 'liquidity_addition'],
    required: true
  },
  hash: {
    type: String,
    sparse: true,
    index: true
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'failed'],
    default: 'pending'
  },
  fromAddress: {
    type: String,
    required: true,
    lowercase: true
  },
  nonce: {
    type: Number
  },
  gasPrice: {
    type: String
  },
  gasLimit: {
    type: String
  },
  value: {
    type: String
  },
  data: {
    type: String
  },
  blockNumber: {
    type: Number,
    sparse: true,
    index: true
  }
}, {
  timestamps: true
});

// Indexes for common queries
TransactionSchema.index({ fromAddress: 1, createdAt: -1 });
TransactionSchema.index({ status: 1 });
TransactionSchema.index({ type: 1, status: 1 });

export const Transaction = mongoose.model<ITransaction>('Transaction', TransactionSchema); 