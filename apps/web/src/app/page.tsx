'use client'

import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

export default function Home(): JSX.Element {
  const { push } = useRouter()

  useEffect(() => {
    push('/setup')
  }, [push])

  return <></>
}
