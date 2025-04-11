import mongoose, { Document, Schema } from 'mongoose';

export interface IImageUpload extends Document {
  originalName: string;
  mimeType: string;
  size: number;
  ipfsHash?: string;
  ipfsUri?: string;
  createdAt: Date;
  ownerAddress: string;
}

const ImageUploadSchema = new Schema<IImageUpload>({
  originalName: {
    type: String,
    required: true
  },
  mimeType: {
    type: String,
    required: true
  },
  size: {
    type: Number,
    required: true
  },
  ipfsHash: {
    type: String,
    sparse: true,
    index: true
  },
  ipfsUri: {
    type: String,
    sparse: true
  },
  ownerAddress: {
    type: String,
    required: true,
    lowercase: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Indexes for common queries
ImageUploadSchema.index({ ownerAddress: 1, createdAt: -1 });
ImageUploadSchema.index({ ipfsHash: 1 });

export const ImageUpload = mongoose.model<IImageUpload>('ImageUpload', ImageUploadSchema); 