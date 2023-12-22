import postcss from '@simple-run/ui/postcss.config.js'

// eslint-disable-next-line node/prefer-global/process
const devtoolsEnabled = process.env.NODE_ENV !== 'production'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  app: {
    baseURL: '/run',
    head: {
      title: 'Simple Run',
    },
    rootId: 'root',
  },

  devtools: { enabled: devtoolsEnabled },

  modules: [
    '@nuxtjs/tailwindcss',
    '@simple-run/ui',
  ],

  postcss,

  ssr: false,

  tailwindcss: {
    cssPath: '@simple-run/ui/global.css',
  },
})
