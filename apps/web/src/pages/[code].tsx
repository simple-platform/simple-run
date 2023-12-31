import customProtocolCheck from 'custom-protocol-check'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'

import InstallAgent from './install-agent'
import { InvalidRequest } from './invalid-request'
import Loading from './loading'

function closeTab() {
  window.close()
  return null
}

function buildRequest(c?: string): string {
  const code = (c || '').trim().toLowerCase()

  if (code === '')
    return ''

  let provider = ''
  let org = ''
  let repo = ''
  let fileToRun = ''

  const parts = code.split('!')

  for (let i = 0; i < parts.length; ++i) {
    const part = parts[i]
    const kvp = part.split(':')

    if (kvp.length !== 2)
      return ''

    const [key, val] = kvp

    switch (key) {
      case 'p':
        provider = val
        break
      case 'o':
        org = val
        break
      case 'r':
        repo = val
        break
      case 'f':
        fileToRun = val
        break
      default:
        return ''
    }
  }

  let url = `simplerun:${provider}?o=${org}&r=${repo}`

  if (fileToRun !== '')
    url = `${url}&f=${fileToRun}`

  return url
}

export default function RunApplication() {
  const router = useRouter()
  const code = router.query.code as string

  const [agentInstalled, setAgentInstalled] = useState<boolean | undefined>(undefined)

  const url = buildRequest(code)

  useEffect(() => {
    if (url === '')
      return

    customProtocolCheck(
      url,
      () => setAgentInstalled(false),
      () => setAgentInstalled(true),
      2000,
    )
  }, [url])

  if (!code)
    return

  return (
    <section className="flex items-center justify-center h-full">
      {url === '' ? <InvalidRequest /> : null}
      {agentInstalled === false ? <InstallAgent /> : <Loading />}
      {agentInstalled === true ? closeTab() : null}
    </section>
  )
}
