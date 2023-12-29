/** @type {import('next').NextConfig} */

let actionsEndpoint = 'https://actions.run.simple.dev'

// eslint-disable-next-line node/prefer-global/process
if (process.env.NODE_ENV === 'development')
  // eslint-disable-next-line node/prefer-global/process
  actionsEndpoint = process.env.SIMPLE_RUN_ACTIONS_URL || 'http://localhost:4000'

module.exports = {
  basePath: '/run',

  env: { actionsEndpoint },

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
