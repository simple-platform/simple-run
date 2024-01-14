import ExclamationTriangleIcon from '@heroicons/react/24/outline/ExclamationTriangleIcon'

export function RepoNotReady() {
  return (
    <div className="alert alert-warning text-sm rounded-md mt-3 md:mt-6 transition" role="alert">
      <ExclamationTriangleIcon className="w-6 h-6 md:w-10 md:h-10" />
      <div>
        <div className="font-semibold">Your repository is not ready to run locally.</div>
        <div>
          Please add either
          {' '}
          <pre className="inline italic">simple-run.yaml</pre>
          {' '}
          or
          {' '}
          <pre className="inline italic">Dockerfile</pre>
          {' '}
          at the root of your repository.
        </div>
      </div>
    </div>
  )
}
