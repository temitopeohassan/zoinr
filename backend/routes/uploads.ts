import express from 'express';
import { upload, uploadImage, getImage } from '../controllers/uploadController';
import { create as createIPFSClient } from 'ipfs-http-client';
import { ethers } from 'ethers';

declare module 'express' {
  interface Request {
    ipfs: ReturnType<typeof createIPFSClient>;
    provider: ethers.JsonRpcProvider;
    user: {
      address: string;
    };
    file?: Express.Multer.File;
  }
}

type CustomRequestHandler = (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => Promise<void> | void;

const router = express.Router();

router.post('/', upload.single('file'), uploadImage as any);
router.get('/:id', getImage as any);

export default router; 