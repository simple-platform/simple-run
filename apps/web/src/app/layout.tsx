// import type { Metadata } from 'next'

import '@simple-run/ui/global.css'

// import { Inter } from 'next/font/google'

// const inter = Inter({ subsets: ['latin'] })

// export const metadata: Metadata = {
//   description: 'Simple Run',
//   title: 'Simple Run',
// }

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}): JSX.Element {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
