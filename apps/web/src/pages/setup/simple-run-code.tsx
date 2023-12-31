import { ClipboardDocumentListIcon } from '@heroicons/react/24/outline'
import Markdown from 'react-markdown'
import rehypeRaw from 'rehype-raw'

import { useAppStore } from '../../lib/store'

// eslint-disable-next-line node/prefer-global/process
const actionsEndpoint = process.env.actionsEndpoint

export function SimpleRunCode() {
  const fileToRun = useAppStore(state => state.setup.fileToRun)
  const repoMetadata = useAppStore(state => state.setup.repoMetadata)

  if (fileToRun === '' && !repoMetadata.simplerun?.config)
    return null

  const { name, org } = repoMetadata
  const { host, protocol } = window.location

  const baseUrl = `${protocol}//${host}/run`

  const parts = ['p:gh', `o:${org}`, `r:${name}`]
  if (fileToRun)
    parts.push(`f:${fileToRun}`)

  const info = parts.join('!')

  const url = `${baseUrl}/${info}`
  const imageUrl = `${actionsEndpoint}/img/${info}`

  const code = `<a href="${url}" target="_blank" alt="Run Locally"><img src="${imageUrl}" style="height: 40px;" alt="Run Locally"/></a>`

  const image = 'simple-run-locally@2x.png'
  const previewImageUrl = host.startsWith('localhost') ? image : `${baseUrl}/${image}`

  const previewCode = `<a href="${url}" target="_blank" alt="Run Locally"><img src="${previewImageUrl}" style="height: 40px;" alt="Run Locally"/></a>`

  const md = `
  # ${org}/${name}
  ---
  ${previewCode}
  `

  return (
    <section className="w-full mt-3 md:mt-6">
      <div className="p-3 md:p-6 space-y-3 md:space-y-6 shadow rounded-lg bg-slate-200 dark:bg-slate-800">
        <div className="test-sm mb-3 md:mb-6">
          <div className="text-sm">
            Please add this code to your repository&apos;s
            {' '}
            <pre className="inline">README.md</pre>
            {' '}
            and you&apos;ll be all set!
          </div>
          <div className="text-xs italic">
            <strong>Note:</strong>
            {' '}
            we currently only support
            {' '}
            <pre className="inline">MacOS</pre>
            . Non-Mac users will not see the button to run your project locally.
          </div>
        </div>
        <div className="flex flex-col md:flex-row space-y-3 md:space-y-0 md:space-x-6">
          <div className="w-full flex bg-slate-950 rounded-lg">
            <code className="p-3 md:p-6 text-sm break-all text-orange-300">{code}</code>
            <div>
              <ClipboardDocumentListIcon className="w-4 h-4 relative right-3 top-3 cursor-pointer text-slate-50 hover:text-orange-300 active:text-indigo-300" onClick={() => navigator.clipboard.writeText(code)} />
            </div>
          </div>
          <div className="flex items-center justify-center bg-slate-50 dark:bg-slate-950 p-3 md:p-6 rounded-lg">
            <Markdown className="block text-center markdown" rehypePlugins={[rehypeRaw]}>{md}</Markdown>
          </div>
        </div>
      </div>
    </section>
  )
}
