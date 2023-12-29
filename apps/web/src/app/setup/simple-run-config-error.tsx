import ExclamationTriangleIcon from '@heroicons/react/24/outline/ExclamationTriangleIcon'

export function SimpleRunConfigError() {
  return (
    <div className="alert alert-warning text-sm rounded-md mt-3 md:mt-6 transition" role="alert">
      <ExclamationTriangleIcon className="w-6 h-6 md:w-10 md:h-10" />
      <div>
        <div className="font-semibold">
          Your
          {' '}
          <pre className="inline italic">simple-run.yaml</pre>
          {' '}
          is invalid.
        </div>
        <div>
          Please resolve Simple Run configuration issues and try again.
        </div>
      </div>
    </div>
  )
}
