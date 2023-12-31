/* eslint-disable react/no-unknown-property */
/* eslint-disable perfectionist/sort-imports */
import 'inter-ui/inter-latin.css'
import 'inter-ui/inter-variable-latin.css'

import '@simple-run/ui/global.css'
import '../styles/local.css'

import type { AppProps } from 'next/app'

import { Outfit } from 'next/font/google'
import Head from 'next/head'

import { StoreProvider } from './store-provider'

const outfit = Outfit({
  display: 'swap',
  preload: true,
  subsets: ['latin'],
  variable: '--font-outfit',
})

export default function App({ Component, pageProps }: AppProps) {
  return (
    <StoreProvider>
      <Head>
        <title>Simple Run</title>
        <meta content="Run containerized applications easily on your local machine."></meta>
      </Head>

      <style global jsx>
        {`
        h1, h2, h3, h4, h5, h6 {
          font-family: ${outfit.style.fontFamily};
        }

        @supports (not (font-variation-settings: normal)) {
          h1, h2, h3, h4, h5, h6 {
            font-family: Inter, ui-sans-serif, system-ui;
          }
        }
      `}

      </style>

      <main className="h-full"><Component {...pageProps} /></main>
    </StoreProvider>
  )
}
