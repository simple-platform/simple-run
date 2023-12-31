import { InformationCircleIcon } from '@heroicons/react/24/outline'

export function SimpleRunYamlFound() {
  return (
    <div className="alert alert-info text-sm rounded-md transition" role="alert">
      <InformationCircleIcon className="w-6 h-6 md:w-10 md:h-10" />
      <div>
        <div className="font-semibold">
          We found
          {' '}
          <pre className="inline italic">simple-run.yaml</pre>
          {' '}
          at your repo root.
        </div>
        <div>We&apos;ll use Simple Run configuration to run your project locally.</div>
      </div>
    </div>
  )
}
