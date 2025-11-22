import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Webpack configuration to exclude Node.js modules from client bundle
  // Required for Privy + WalletConnect dependencies compatibility
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
        net: false,
        tls: false,
        crypto: false,
        stream: false,
        url: false,
        zlib: false,
        http: false,
        https: false,
        assert: false,
        os: false,
        path: false,
        worker_threads: false,
        child_process: false,
      };
    }
    return config;
  },
};

export default nextConfig;
