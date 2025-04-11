import { Request, Response, NextFunction } from 'express';
import { verifyMessage } from 'ethers';

declare global {
  namespace Express {
    interface Request {
      user: {
        address: string;
      };
    }
  }
}

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return res.status(401).json({ message: 'No authorization header' });
    }

    const [bearer, token] = authHeader.split(' ');
    if (bearer !== 'Bearer' || !token) {
      return res.status(401).json({ message: 'Invalid authorization format' });
    }

    // Token format: address.timestamp.signature
    const [address, timestamp, signature] = token.split('.');
    if (!address || !timestamp || !signature) {
      return res.status(401).json({ message: 'Invalid token format' });
    }

    // Check if timestamp is within 5 minutes
    const ts = parseInt(timestamp);
    if (Date.now() - ts > 5 * 60 * 1000) {
      return res.status(401).json({ message: 'Token expired' });
    }

    // Verify signature
    const message = `Authenticate to Zora Coin Launcher: ${timestamp}`;
    const recoveredAddress = verifyMessage(message, signature);

    if (recoveredAddress.toLowerCase() !== address.toLowerCase()) {
      return res.status(401).json({ message: 'Invalid signature' });
    }

    // Attach user to request
    req.user = {
      address: address.toLowerCase()
    };

    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(401).json({ message: 'Authentication failed' });
  }
}; 