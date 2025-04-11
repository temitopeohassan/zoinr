import { ethers } from 'ethers';

export const ZoraCoinFactoryABI = [
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "symbol",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "owner",
        "type": "address"
      },
      {
        "internalType": "string",
        "name": "metadataUri",
        "type": "string"
      },
      {
        "internalType": "address[]",
        "name": "initialReceivers",
        "type": "address[]"
      },
      {
        "internalType": "uint256[]",
        "name": "initialAmounts",
        "type": "uint256[]"
      }
    ],
    "name": "createCoin",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "creator",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "coinAddress",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "symbol",
        "type": "string"
      }
    ],
    "name": "CoinCreated",
    "type": "event"
  }
] as const;

export interface CoinCreatedEvent {
  creator: string;
  coinAddress: string;
  name: string;
  symbol: string;
}

export interface ZoraCoinFactory extends ethers.BaseContract {
  createCoin(
    name: string,
    symbol: string,
    owner: string,
    metadataUri: string,
    initialReceivers: string[],
    initialAmounts: bigint[]
  ): Promise<ethers.ContractTransactionResponse>;

  // Event handling
  on(event: "CoinCreated", listener: (creator: string, coinAddress: string, name: string, symbol: string) => void): Promise<this>;
  off(event: "CoinCreated", listener: (creator: string, coinAddress: string, name: string, symbol: string) => void): Promise<this>;
  once(event: "CoinCreated", listener: (creator: string, coinAddress: string, name: string, symbol: string) => void): Promise<this>;
  emit(event: "CoinCreated", creator: string, coinAddress: string, name: string, symbol: string): Promise<boolean>;
} 