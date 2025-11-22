import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Empty Turbopack config to acknowledge Next.js 16's default bundler
  turbopack: {},
  // Webpack configuration for fallback when using --webpack flag
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
