import { useRouter } from 'next/router'

export default function RunApplication() {
  const router = useRouter()
  const { code } = router.query

  return (
    <section>
      Run Application. Code:
      {' '}
      {code}
    </section>
  )
}
