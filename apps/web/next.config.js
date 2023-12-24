/** @type {import('next').NextConfig} */
module.exports = {
  basePath: '/run',
  poweredByHeader: false,
  reactStrictMode: true,

  async redirects() {
    return [{
      destination: '/setup',
      permanent: true,
      source: '/',
    }]
  },

  transpilePackages: ['@simple-run/ui'],
}
