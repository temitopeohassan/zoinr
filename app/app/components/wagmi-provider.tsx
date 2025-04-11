"use client";

import { ReactNode } from 'react';
import { cookieToInitialState } from 'wagmi';
import { getConfig } from '../wagmi';
import { Providers } from '../providers';

export function WagmiProvider({ 
  children,
  cookie 
}: { 
  children: ReactNode;
  cookie: string | null;
}) {
  const initialState = cookieToInitialState(
    getConfig(),
    cookie
  );

  return (
    <Providers initialState={initialState}>
      {children}
    </Providers>
  );
} 