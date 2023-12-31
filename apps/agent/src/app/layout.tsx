/* eslint perfectionist/sort-imports: "off" */
import { Outfit } from 'next/font/google'

import 'inter-ui/inter-variable-latin.css'
import 'inter-ui/inter-latin.css'

import '@simple-run/ui/global.css'
import './local.css'

import Titlebar from './titlebar'

import { StoreProvider } from './store-provider'

const outfit = Outfit({
  display: 'swap',
  preload: true,
  subsets: ['latin'],
  variable: '--font-outfit',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}): JSX.Element {
  return (
    <html lang="en">
      <body className={outfit.variable}>
        <Titlebar />
        <StoreProvider>{children}</StoreProvider>
      </body>
    </html>
  )
}
