/* eslint perfectionist/sort-imports: "off" */
import type { Metadata } from 'next'
import { Outfit } from 'next/font/google'

import 'inter-ui/inter-variable-latin.css'
import 'inter-ui/inter-latin.css'

import '@simple-run/ui/global.css'
import './local.css'
import Titlebar from './titlebar'

const outfit = Outfit({
  display: 'swap',
  preload: true,
  subsets: ['latin'],
  variable: '--font-outfit',
})

// eslint-disable-next-line react-refresh/only-export-components
export const metadata: Metadata = {
  description: 'Run containerized applications easily on your local machine.',
  title: 'Simple Run',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}): JSX.Element {
  return (
    <html lang="en">
      <body className={outfit.variable}>
        <Titlebar />
        <main>{children}</main>
      </body>
    </html>
  )
}
