"use client";

import { useContractRead, useContractWrite } from 'wagmi';
import { parseEther } from 'viem';
import { type Abi, parseAbiItem } from 'viem';
import CrowdFundingABI from '@/contracts/CrowdFunding.json';

const CONTRACT_ADDRESS = process.env.NEXT_PUBLIC_CROWDFUNDING_CONTRACT_ADDRESS as `0x${string}`;
const contractConfig = {
  address: CONTRACT_ADDRESS,
  abi: CrowdFundingABI as unknown as Abi,
} as const;

export function useCrowdfundingContract() {
  const { writeContract: createCampaignFn } = useContractWrite({
    ...contractConfig,
    functionName: 'createCampaign',
  });

  const { writeContract: donateFn } = useContractWrite({
    ...contractConfig,
    functionName: 'donate',
  });

  const { data: campaignData } = useContractRead({
    ...contractConfig,
    functionName: 'getCampaign',
  });

  const createCampaign = async (
    title: string, 
    description: string, 
    goal: bigint, 
    durationInDays: number
  ) => {
    return createCampaignFn({
      ...contractConfig,
      args: [title, description, goal, BigInt(durationInDays)],
    });
  };

  const donate = async (campaignId: number, amount: bigint) => {
    return donateFn({
      ...contractConfig,
      args: [BigInt(campaignId)],
      value: amount,
    });
  };

  return {
    createCampaign,
    donate,
    campaignData,
  };
} 