/** @type {import('next').NextConfig} */

let actionsEndpoint = 'https://actions.run.simple.dev'

// eslint-disable-next-line node/prefer-global/process
if (process.env.NODE_ENV === 'development')
  // eslint-disable-next-line node/prefer-global/process
  actionsEndpoint = process.env.SIMPLE_RUN_ACTIONS_ENDPOINT || 'http://localhost:4000'

module.exports = {
  basePath: '/run',

  env: { actionsEndpoint },

  output: 'export',

  poweredByHeader: false,
  reactStrictMode: true,

  transpilePackages: ['@simple-run/ui'],
}
