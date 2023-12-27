'use client'

import { useDispatch } from 'react-redux'

import type { AppDispatch } from '../../lib/store'

import { setFileToRun } from '../../lib/features/setup-slice'
import { useAppStore } from '../../lib/store'
import { RepoNotReady } from './repo-not-ready'

export function SimpleRunConfig() {
  const fileToRun = useAppStore(state => state.setup.fileToRun)
  const repoMetadata = useAppStore(state => state.setup.repoMetadata)
  const dispatch = useDispatch<AppDispatch>()

  if (!repoMetadata.name)
    return null

  const { dockerFiles } = repoMetadata
  if (dockerFiles.length === 0)
    return <RepoNotReady />

  return (
    <section className="mt-3 md:mt-6">
      <div className="w-full">
        <label className="label">
          <span className="label-text-alt">
            <strong>File to run</strong>
          </span>
        </label>
        <select className="select select-bordered w-full" name="file-to-run" onChange={e => dispatch(setFileToRun(e.target.value))} value={fileToRun}>
          <option disabled value="">Which file should we run?</option>
          {dockerFiles.map(file => <option key={file} value={file}>{file}</option>)}
        </select>
      </div>
    </section>
  )
}
