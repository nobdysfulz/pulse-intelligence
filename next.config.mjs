import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  
  webpack: (config) => {
    // Configure path aliases for webpack
    config.resolve.alias = {
      ...config.resolve.alias,
      '@': path.resolve(__dirname, './src'),
      '@/components': path.resolve(__dirname, './src/components'),
      '@/lib': path.resolve(__dirname, './src/lib'),
      '@/utils': path.resolve(__dirname, './src/utils'),
      '@/api': path.resolve(__dirname, './src/api'),
      '@/hooks': path.resolve(__dirname, './src/hooks'),
      '@/integrations': path.resolve(__dirname, './src/integrations'),
      '@/config': path.resolve(__dirname, './src/config'),
    };
    return config;
  },
  
  // Allow external images if needed
  images: {
    domains: [],
    unoptimized: true,
  },
  
  // Suppress hydration warnings during development
  onDemandEntries: {
    maxInactiveAge: 25 * 1000,
    pagesBufferLength: 2,
  },
  
  // Transpile packages if needed
  transpilePackages: [],
};

export default nextConfig;
