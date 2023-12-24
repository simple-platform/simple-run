'use client'

import { ChevronDoubleRightIcon } from '@heroicons/react/24/outline'
import { Header } from '@simple-run/ui/header'
import { type ChangeEvent, useState } from 'react'

function RepoInput(isSmallDevice: boolean) {
  const placeholder = isSmallDevice
    ? 'https://github.com/simple...'
    : 'https://github.com/simple-platform/simple-run'

  const errorMessage = 'We are unable to load details about this repository.'
  const [error, setError] = useState('')

  function handleRepoUrlChange(e: ChangeEvent<HTMLInputElement>) {
    const repoUrl = e.target.value.trim().toLowerCase()

    if (repoUrl === '')
      return

    if (!repoUrl.startsWith('https://'))
      setError(errorMessage)

    // @todo: call github
  }

  return (
    <section className="max-w-sm md:max-w-2xl w-full mt-6 md:mt-12">
      <div className="p-3 md:px-6 md:py-6 shadow rounded-lg bg-slate-200 dark:bg-slate-800">
        <label className="label" htmlFor="github_url">
          <span className="label-text-alt">
            GitHub URL
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
          <input autoComplete="off" className="input input-bordered w-full join-item" name="github_url" onBlur={handleRepoUrlChange} onFocus={() => setError('')} placeholder={placeholder} type="text" />
          <button className="btn join-item input-bordered border-l-0">
            <ChevronDoubleRightIcon className="w-6" />
          </button>
        </div>
        <span className="text-sm italic text-red-600 transition" hidden={error === ''}>{error}</span>
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
