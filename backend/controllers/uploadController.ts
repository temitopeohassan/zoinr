import { Request, Response } from 'express';
import { ImageUpload } from '../models/ImageUpload';
import { create as createIPFSClient } from 'ipfs-http-client';
import multer from 'multer';

declare module 'express' {
  interface Request {
    ipfs: ReturnType<typeof createIPFSClient>;
    file?: Express.Multer.File;
  }
}

export const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }
});

export const uploadImage = async (req: Request, res: Response) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'No file uploaded' });
    
    const result = await req.ipfs.add(req.file.buffer);
    const upload = new ImageUpload({
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      ipfsHash: result.path,
      ipfsUri: `ipfs://${result.path}`,
      ownerAddress: req.user.address.toLowerCase()
    });
    await upload.save();
    
    res.status(201).json(upload);
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ message: 'Upload failed' });
  }
};

export const getImage = async (req: Request, res: Response) => {
  try {
    const upload = await ImageUpload.findById(req.params.id);
    if (!upload) return res.status(404).json({ message: 'Image not found' });
    res.json(upload);
  } catch (error) {
    console.error('Get image error:', error);
    res.status(500).json({ message: 'Failed to fetch image' });
  }
}; 