'use client'

import Markdown from 'react-markdown'
import rehypeRaw from 'rehype-raw'

import { useAppStore } from '../../lib/store'

export function SimpleRunCode() {
  const fileToRun = useAppStore(state => state.setup.fileToRun)
  const repoMetadata = useAppStore(state => state.setup.repoMetadata)

  if (fileToRun === '')
    return null

  const { name, org } = repoMetadata
  const { host, protocol } = window.location

  const baseUrl = `${protocol}://${host}/run`

  const info = `p:gh|o:${org}|r:${name}|f:${fileToRun}`
  const url = `${baseUrl}/${info}`

  const image = 'simple-run-locally@2x.png'
  const imageUrl = host.startsWith('localhost') ? image : `${baseUrl}/${image}`

  // https://github.com/go-gitea/gitea

  const code = `<a href="${url}" target="_blank" alt="Run Locally"><img src="${imageUrl}" style="height: 40px;" alt="Run Locally"/></a>`

  const md = `
  # ${org}/${name}
  ---
  ${code}
  `

  return (
    <section className="max-w-sm md:max-w-3xl w-full mt-3 md:mt-6">
      <div className="p-3 md:p-6 space-y-3 md:space-y-6 shadow rounded-lg bg-slate-200 dark:bg-slate-800">
        <div className="test-sm mb-3 md:mb-6">
          Please add this code to your repository&apos;s
          {' '}
          <pre className="inline">README.md</pre>
          {' '}
          and you&apos;ll be all set!
        </div>
        <div className="flex flex-col md:flex-row space-y-3 md:space-y-0 md:space-x-6">
          <div className="w-full">
            <pre className="bg-slate-950 rounded-lg whitespace-normal p-3 md:p-6">
              <code className="text-sm">{code}</code>
            </pre>
          </div>
          <div className="flex items-center justify-center bg-slate-50 dark:bg-slate-950 p-3 md:p-6 rounded-lg">
            <Markdown className="block text-center markdown" rehypePlugins={[rehypeRaw]}>{md}</Markdown>
          </div>
        </div>
      </div>
    </section>
  )
}
