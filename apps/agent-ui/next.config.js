/** @type {import('next').NextConfig} */

module.exports = {
  distDir: '../agent/frontend/dist',
  output: 'export',

  poweredByHeader: false,
  reactStrictMode: true,

  transpilePackages: ['@simple-run/ui'],
}
