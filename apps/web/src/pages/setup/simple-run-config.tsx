import { useDispatch } from 'react-redux'

import type { NameFilePair, SimplerunConfig } from '../../lib/features/setup-slice'
import type { AppDispatch } from '../../lib/store'

import { setFileToRun } from '../../lib/features/setup-slice'
import { useAppStore } from '../../lib/store'
import { RepoNotReady } from './repo-not-ready'
import { SimpleRunConfigError } from './simple-run-config-error'
import { SimpleRunYamlFound } from './simple-run-yaml-found'

function showFiles(step: string, files: NameFilePair[]) {
  return (
    <li>
      <div className="font-semibold">{step}</div>
      <ol className="w-full list-disc pl-3 md:pl-6">
        {
          files.map(({ file, name }, idx) => (
            <li className="w-full" key={`${step}-${idx}`}>
              {name}
              {' '}
              <span className="italic">
                (
                <pre className="inline">{file}</pre>
                )
              </span>
            </li>
          ))
        }
      </ol>
    </li>
  )
}

function showConfig(config: SimplerunConfig) {
  return (
    <section>
      <div className="text-sm mt-3 md:mt-6 mb-1.5 md:mb-3">We&apos;ll use the following execution order to run your project locally.</div>
      <div className="text-sm bg-slate-50 dark:bg-slate-950 w-full rounded p-1.5 md:p-3 space-y-1.5 md:space-y-3">
        <ol className="space-y-1.5 md:space-y-3">
          {config.prescripts && config.prescripts.length > 0
            ? showFiles('Pre Scripts', config.prescripts)
            : null}

          <li>
            <div className="font-semibold">Docker Compose</div>
            <ol className="w-full list-disc pl-3 md:pl-6">
              <li className="w-full">
                <span className="italic">
                  <pre className="inline">{config.compose_file}</pre>
                </span>
              </li>
            </ol>
          </li>

          {config.postscripts && config.postscripts.length > 0
            ? showFiles('Post Scripts', config.postscripts)
            : null}
        </ol>
      </div>
    </section>
  )
}

export function SimpleRunConfig() {
  const fileToRun = useAppStore(state => state.setup.fileToRun)
  const repoMetadata = useAppStore(state => state.setup.repoMetadata)
  const dispatch = useDispatch<AppDispatch>()

  const { dockerFiles, name, simplerun } = repoMetadata

  if (!name)
    return null

  if (!simplerun && dockerFiles.length === 0)
    return <RepoNotReady />

  if (!simplerun) {
    return (
      <section>
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

  return (
    <section>
      <SimpleRunYamlFound />
      {simplerun.config ? showConfig(simplerun.config) : <SimpleRunConfigError />}
    </section>
  )
}
