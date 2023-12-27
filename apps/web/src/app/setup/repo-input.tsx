'use client'

import { get } from '@simple-run/ui/helpers'
import { useCallback, useEffect, useState } from 'react'
import { useDispatch } from 'react-redux'
import { useDebounce } from 'use-debounce'

import { setErrors, setRepoMetadata } from '../../lib/features/setup-slice'
import { type AppDispatch, useAppStore } from '../../lib/store'

// eslint-disable-next-line node/prefer-global/process
const actionsEndpoint = process.env.actionsEndpoint

export function RepoInput() {
  const placeholder = 'https://github.com/simple-platform/simple-run'

  const errorInvalidFormat = 'Please enter a valid repository URL'

  const [repoUrlValue, setRepoUrlValue] = useState('')
  const [repoUrl] = useDebounce(repoUrlValue, 1000)

  const errors = useAppStore(state => state.setup.errors)

  const dispatch = useDispatch<AppDispatch>()

  const getRepoMetadata = useCallback(async (repoUrl: string) => {
    const resp = await get(`${actionsEndpoint}/repo/github/${encodeURIComponent(repoUrl)}`)
    const data = await resp.json()

    if (resp.status !== 200) {
      dispatch(setErrors(data.errors))
      return
    }

    dispatch(setRepoMetadata(data))
  }, [dispatch])

  useEffect(() => {
    if (repoUrl === '')
      return () => {}

    if (!repoUrl.startsWith('https://')) {
      dispatch(setErrors([errorInvalidFormat]))
      return
    }

    getRepoMetadata(repoUrl)

    return () => {}
  }, [repoUrl, getRepoMetadata, dispatch])

  return (
    <section>
      <label className="label">
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

      <input autoComplete="off" className="input input-bordered w-full join-item" name="repo-url" onChange={e => setRepoUrlValue(e.target.value.trim().toLowerCase())} placeholder={placeholder} type="text" />

      {errors.map((error, idx) =>
        <span className="text-xs italic text-red-600 transition font-semibold" key={`err-${idx}`}>{error}</span>,
      )}
    </section>
  )
}
