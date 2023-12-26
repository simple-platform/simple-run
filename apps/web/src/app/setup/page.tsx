'use client'

import { Header } from '@simple-run/ui/header'
import { get } from '@simple-run/ui/helpers'
import { useEffect, useState } from 'react'
import { useDebounce } from 'use-debounce'

// eslint-disable-next-line node/prefer-global/process
const actionsEndpoint = process.env.actionsEndpoint

interface RepoDetails {
  defaultBranch: string
  desc: string
  iconUrl: string
  name: string
  org: string
}

function ShowRepoDetails(repoDetails?: RepoDetails) {
  if (!repoDetails)
    return (<></>)

  const { desc, iconUrl, name, org } = repoDetails
  const fullName = `${org}/${name}`

  return (
    <article className="card card-side bg-slate-50 dark:bg-slate-950 shadow-md rounded-md mt-6">
      <figure className="p-3 w-32 min-w-32 flex">
        <img alt={fullName} className="rounded-md" src={iconUrl} />
      </figure>
      <div className="card-body p-3">
        <h3 className="card-title">{fullName}</h3>
        <p className="line-clamp-3">{desc}</p>
      </div>
    </article>
  )
}

function RepoInput(isSmallDevice: boolean) {
  const placeholder = isSmallDevice
    ? 'https://github.com/simple...'
    : 'https://github.com/simple-platform/simple-run'

  const errorInvalidFormat = 'Please enter a valid repository URL'

  const [errors, setErrors] = useState<string[]>([])

  const [repoUrlValue, setRepoUrl] = useState('')
  const [repoUrl] = useDebounce(repoUrlValue, 1000)

  const [repoDetails, setRepoDetails] = useState<RepoDetails>()

  async function getRepoDetails(repoUrl: string) {
    const resp = await get(`${actionsEndpoint}/repo/github/${encodeURIComponent(repoUrl)}`)
    const data = await resp.json()

    if (resp.status !== 200) {
      setErrors(data.errors)
      return
    }

    setRepoDetails(data)
  }

  useEffect(() => {
    if (repoUrl === '')
      return

    if (!repoUrl.startsWith('https://')) {
      setErrors([errorInvalidFormat])
      return
    }

    getRepoDetails(repoUrl)

    return () => setErrors([])
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

        <input autoComplete="off" className="input input-bordered w-full join-item" name="github_url" onChange={e => setRepoUrl(e.target.value.trim().toLowerCase())} placeholder={placeholder} type="text" />

        {errors.map((error, idx) =>
          <span className="text-xs italic text-red-600 transition font-semibold" key={`err-${idx}`}>{error}</span>,
        )}

        {errors.length > 0 ? <></> : ShowRepoDetails(repoDetails)}
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
