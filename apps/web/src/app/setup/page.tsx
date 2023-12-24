'use client'

import { ChevronDoubleRightIcon } from '@heroicons/react/24/outline'
import { Header } from '@simple-run/ui/header'
import { useEffect, useState } from 'react'
import { useDebounce } from 'use-debounce'

function RepoInput(isSmallDevice: boolean) {
  const placeholder = isSmallDevice
    ? 'https://github.com/simple...'
    : 'https://github.com/simple-platform/simple-run'

  const errorInvalidFormat = 'Please enter a valid repository URL'

  const [error, setError] = useState('')
  const [hasError, setHasError] = useState(false)

  useEffect(() => {
    setHasError(error !== '')
  }, [error])

  const [repoUrlValue, setRepoUrl] = useState('')
  const [repoUrl] = useDebounce(repoUrlValue, 1000)

  useEffect(() => {
    if (repoUrl === '')
      return

    if (!repoUrl.startsWith('https://'))
      setError(errorInvalidFormat)

    return () => setError('')
  }, [repoUrl])

  return (
    <section className="max-w-sm md:max-w-2xl w-full mt-6 md:mt-12">
      <div className="p-3 md:px-6 md:py-6 shadow rounded-lg bg-slate-200 dark:bg-slate-800">
        <label className="label" htmlFor="github_url">
          <span className="label-text-alt">
            <strong>GitHub URL</strong>
            {' '}
            <span className="italic">
              ( we only support
              {' '}
              <span className="underline underline-offset-2 decoration-dotted">public</span>
              {' '}
              repos for now )
            </span>
          </span>
        </label>
        <div className="join w-full">
          <input autoComplete="off" className="input input-bordered w-full join-item" name="github_url" onChange={e => setRepoUrl(e.target.value.trim().toLowerCase())} placeholder={placeholder} type="text" />
          <button className="btn join-item input-bordered border-l-0">
            <ChevronDoubleRightIcon className="w-6" />
          </button>
        </div>
        <span className="text-xs italic text-red-600 transition" hidden={!hasError}>{error}</span>
      </div>
    </section>
  )
}

export default function Page(): JSX.Element {
  // @todo: properly implement using media query
  const isSmallDevice = false
  const title = isSmallDevice ? 'Let\'s setup your project!' : 'Let\'s setup your project to run locally!'

  return (
    <main className="h-full flex flex-col justify-center items-center p-6 md:p-12">
      <Header className="text-center max-w-3xl" title={title} />
      {RepoInput(false)}
    </main>
  )
}
